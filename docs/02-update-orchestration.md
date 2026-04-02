# Scenario 1: Update Orchestration

Demonstrates staged Kubernetes version upgrades across dev → staging → production.

## Check Current Versions

```bash
RG=$(terraform -chdir=../terraform output -raw resource_group_name)
FLEET=$(terraform -chdir=../terraform output -raw fleet_name)

az fleet member list --resource-group $RG --fleet-name $FLEET -o table
```

## View Update Strategy

```bash
az fleet updatestrategy show --resource-group $RG --fleet-name $FLEET --name staged-rollout
```

## Create an Update Run

```bash
az fleet updaterun create \
  --resource-group $RG \
  --fleet-name $FLEET \
  --name upgrade-demo \
  --upgrade-type Full \
  --kubernetes-version <target-version> \
  --update-strategy-name staged-rollout
```

## Start the Rollout

```bash
az fleet updaterun start \
  --resource-group $RG \
  --fleet-name $FLEET \
  --name upgrade-demo
```

## Monitor Progress

```bash
az fleet updaterun show \
  --resource-group $RG \
  --fleet-name $FLEET \
  --name upgrade-demo \
  -o table
```

Watch in the Azure portal: **Fleet Manager → Update runs** for a visual timeline of the staged rollout.
