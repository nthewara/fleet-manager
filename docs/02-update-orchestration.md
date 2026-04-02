# Update Orchestration Demo — CLI Commands

Based on [AKS Upgrade Best Practices with Fleet Manager](https://github.com/nthewara/fleet-manager) — control plane and node pools upgraded separately for safety and visibility.

## Prerequisites

```bash
RG="fleetdemo-xuji"
FLEET="fleetdemo-fleet-xuji"
```

## Pre-flight: Check Current State

```bash
# Current K8s versions
az fleet member list -g $RG --fleet-name $FLEET -o table

# Available upgrade targets
az aks get-upgrades -g $RG -n fleetdemo-aks-dev-xuji \
  --query "controlPlaneProfile.upgrades[].kubernetesVersion" -o tsv

# Current node images
for c in fleetdemo-aks-dev-xuji fleetdemo-aks-stg-xuji fleetdemo-aks-prod-xuji; do
  IMG=$(az aks show -g $RG -n $c --query "agentPoolProfiles[0].nodeImageVersion" -o tsv)
  VER=$(az aks show -g $RG -n $c --query "kubernetesVersion" -o tsv)
  echo "$c: K8s=$VER NodeImage=$IMG"
done

# View update strategy
az fleet updatestrategy show -g $RG --fleet-name $FLEET --name staged-rollout
```

## Step 1: Control Plane Only Upgrade (K8s 1.33 → 1.34)

Upgrades API server, etcd, scheduler, and controller-manager on all 3 clusters.
**Zero pod disruption** — workloads keep running throughout.

```bash
# Create the update run
az fleet updaterun create \
  -g $RG --fleet-name $FLEET \
  --name cp-upgrade-134 \
  --upgrade-type ControlPlaneOnly \
  --kubernetes-version 1.34.4 \
  --update-strategy-name staged-rollout

# Start the rollout
az fleet updaterun start \
  -g $RG --fleet-name $FLEET \
  --name cp-upgrade-134

# Monitor progress
az fleet updaterun show \
  -g $RG --fleet-name $FLEET \
  --name cp-upgrade-134 -o table
```

**What to watch:**
- Fleet Monitor dashboard should stay **all green** — no downtime during control plane upgrade
- Each stage completes in ~5 min per cluster
- Staged rollout: dev → (60s wait) → staging → (120s wait) → production

**Verify after completion:**
```bash
for c in fleetdemo-aks-dev-xuji fleetdemo-aks-stg-xuji fleetdemo-aks-prod-xuji; do
  CP=$(az aks show -g $RG -n $c --query "kubernetesVersion" -o tsv)
  NODE=$(az aks show -g $RG -n $c --query "agentPoolProfiles[0].currentOrchestratorVersion" -o tsv)
  echo "$c: ControlPlane=$CP Nodes=$NODE"
done
```

Expected: Control plane = 1.34.4, Nodes still on 1.33.x (split version state — this is expected and supported)

## Step 2: Node Image Upgrade

Updates node OS images and kubelet version. **This is where pods get disrupted** — nodes are cordoned, drained, and reimaged one by one.

```bash
# Create the update run
az fleet updaterun create \
  -g $RG --fleet-name $FLEET \
  --name node-upgrade-134 \
  --upgrade-type NodeImageOnly \
  --node-image-selection Latest \
  --update-strategy-name staged-rollout

# Start the rollout
az fleet updaterun start \
  -g $RG --fleet-name $FLEET \
  --name node-upgrade-134

# Monitor progress
az fleet updaterun show \
  -g $RG --fleet-name $FLEET \
  --name node-upgrade-134 -o table
```

**What to watch:**
- Fleet Monitor dashboard shows **red/yellow** as each cluster's pods restart during node drain
- Dev goes first — you'll see brief downtime, then recovery
- After 60s wait, staging follows with the same pattern
- After 120s wait, production upgrades last
- Each cluster takes ~10-15 min for node pool upgrade

**Verify after completion:**
```bash
for c in fleetdemo-aks-dev-xuji fleetdemo-aks-stg-xuji fleetdemo-aks-prod-xuji; do
  CP=$(az aks show -g $RG -n $c --query "kubernetesVersion" -o tsv)
  NODE=$(az aks show -g $RG -n $c --query "agentPoolProfiles[0].currentOrchestratorVersion" -o tsv)
  IMG=$(az aks show -g $RG -n $c --query "agentPoolProfiles[0].nodeImageVersion" -o tsv)
  echo "$c: CP=$CP Nodes=$NODE Image=$IMG"
done
```

## Why Separate Upgrades?

| Aspect | Control Plane | Node Pool |
|--------|--------------|-----------|
| **Duration** | ~5 min/cluster | ~10-15 min/cluster |
| **Pod disruption** | None | Yes (drain + reimage) |
| **Risk** | Low (API server restart only) | Medium (pod eviction) |
| **Rollback** | Difficult | Blue-green possible |

Separating them gives you:
1. **Faster validation** — verify API compatibility before touching workloads
2. **Clear downtime window** — know exactly when pods will be disrupted
3. **Better demo visibility** — Fleet Monitor shows the difference clearly

## Emergency: Stop an Update Run

```bash
az fleet updaterun stop \
  -g $RG --fleet-name $FLEET \
  --name <run-name>
```

## Portal View

Monitor in Azure Portal: **Fleet Manager → Update runs** for a visual timeline of each stage.

## Fleet Monitor Dashboard

Open the Fleet Monitor at the monitor cluster IP to watch real-time health during upgrades:
- 🟢 Green = cluster healthy
- 🔴 Red = cluster offline (being upgraded)
- Uptime timeline shows the exact downtime window per cluster
