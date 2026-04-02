# AKS Fleet Manager Demo

Multi-cluster Kubernetes management demo environment using AKS Fleet Manager with Terraform, a sample app, and guided demo scenarios.

## 🎯 Demo Scenarios

This demo showcases three core Fleet Manager capabilities:

### Scenario 1: Coordinated Update Orchestration
Roll out a Kubernetes version upgrade across 3 AKS clusters in a staged sequence: **dev → staging → production** with configurable wait times between stages. Demonstrates how Fleet Manager prevents upgrade chaos across multi-cluster environments.

### Scenario 2: Resource Propagation (Hub Cluster)
Deploy a sample multi-region web app from the hub cluster to member clusters using `ClusterResourcePlacement`. Shows how infrastructure tooling and applications can be pushed to the right clusters based on labels.

### Scenario 3: Cross-Cluster Load Balancing
Expose the sample app across multiple clusters with DNS-based load balancing. Demonstrates active-active multi-region deployments.

## 🏗️ Architecture

```
                    ┌──────────────────────────────┐
                    │     AKS Fleet Manager         │
                    │     (Hub Cluster)             │
                    │  ┌─────────────────────────┐  │
                    │  │  KubeFleet Controllers   │  │
                    │  │  Fleet Networking Mgr    │  │
                    │  │  CRP / Placement Engine  │  │
                    │  └─────────────────────────┘  │
                    └──────────┬───────────────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
    ┌─────────▼────────┐ ┌────▼──────────┐ ┌───▼──────────────┐
    │  AKS Cluster 1   │ │ AKS Cluster 2 │ │  AKS Cluster 3   │
    │  (Dev)           │ │ (Staging)     │ │  (Production)    │
    │                  │ │               │ │                  │
    │  Labels:         │ │ Labels:       │ │  Labels:         │
    │  env=dev         │ │ env=staging   │ │  env=prod        │
    │  region=aueast   │ │ region=aueast │ │  region=aueast   │
    │                  │ │               │ │                  │
    │  ┌────────────┐  │ │ ┌──────────┐  │ │  ┌────────────┐  │
    │  │ Sample App │  │ │ │Sample App│  │ │  │ Sample App │  │
    │  │ (v1/v2)    │  │ │ │(v1/v2)   │  │ │  │ (v1/v2)    │  │
    │  └────────────┘  │ │ └──────────┘  │ │  └────────────┘  │
    └──────────────────┘ └──────────────┘ └──────────────────┘
```

### Azure Resources Deployed

| Resource | Description | Estimated Cost |
|----------|-------------|---------------|
| **Fleet Manager** (hub) | Fleet resource with hub cluster (Standard_DS3_v2) | ~$3.50/day |
| **AKS Cluster - Dev** | 1 node, Standard_B2ms | ~$2.50/day |
| **AKS Cluster - Staging** | 1 node, Standard_B2ms | ~$2.50/day |
| **AKS Cluster - Production** | 2 nodes, Standard_B2ms | ~$5.00/day |
| **ACR** | Basic tier for sample app images | ~$0.17/day |
| **Log Analytics** | Shared workspace | ~$0.10/day |
| **Total** | | **~$14/day** |

## 📁 Repository Structure

```
fleet-manager/
├── README.md                    # This file
├── terraform/                   # Infrastructure as Code
│   ├── main.tf                  # Core resources (RG, ACR, LAW)
│   ├── fleet.tf                 # Fleet Manager + hub cluster
│   ├── clusters.tf              # 3 AKS member clusters
│   ├── providers.tf             # Provider config
│   ├── variables.tf             # Input variables
│   ├── terraform.tfvars         # Default values
│   └── outputs.tf               # Useful outputs
├── app/                         # Sample demo application
│   ├── Dockerfile               # Container image
│   ├── app.py                   # Flask app with cluster info
│   ├── templates/
│   │   └── index.html           # Dashboard UI
│   └── k8s/                     # Kubernetes manifests
│       ├── namespace.yaml
│       ├── deployment.yaml
│       ├── service.yaml
│       └── crp.yaml             # ClusterResourcePlacement
├── docs/                        # Demo walkthroughs
│   ├── 01-deploy-infra.md       # Step 1: Deploy with Terraform
│   ├── 02-update-orchestration.md  # Scenario 1: Staged upgrades
│   ├── 03-resource-propagation.md  # Scenario 2: CRP demo
│   └── 04-cleanup.md            # Teardown
└── scripts/                     # Helper scripts
    ├── build-app.sh             # Build and push to ACR
    └── demo-reset.sh            # Reset demo state
```

## 🚀 Quick Start

### Prerequisites
- Azure subscription
- `az` CLI with `fleet` extension
- `terraform` >= 1.5
- `kubectl`
- `docker` (for building sample app)

### Deploy

```bash
# 1. Deploy infrastructure
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# 2. Build and push sample app
cd ../scripts
./build-app.sh

# 3. Follow demo scenarios in docs/
```

### Cleanup

```bash
cd terraform
terraform destroy
```

## 🎮 Sample Application

The demo includes a **Fleet Dashboard** — a lightweight Flask web app that displays:

- **Cluster identity** — which cluster is serving the request (name, region, node)
- **Fleet membership** — labels, environment, fleet status
- **Version info** — Kubernetes version, node image version
- **Request routing** — shows which cluster handled each request (for cross-cluster LB demo)

The app uses distinct colour themes per environment (🟢 Dev, 🟡 Staging, 🔴 Production) so it's visually obvious which cluster is responding during demos.

## 📖 Demo Flow

### 1. Deploy Infrastructure (~15 min)
Terraform creates the fleet, 3 AKS clusters, and joins them as members.

### 2. Update Orchestration Demo (~20 min)
- Show current K8s versions across clusters
- Create an update strategy: dev → staging → prod
- Execute an update run
- Monitor staged rollout in Azure portal

### 3. Resource Propagation Demo (~15 min)
- Deploy sample app to hub cluster
- Create CRP targeting `env=prod` clusters
- Watch app propagate to production
- Update CRP to `PickAll` — app spreads to all clusters
- Show label-based scheduling

### 4. Cross-Cluster Load Balancing Demo (~10 min)
- Expose service across clusters
- Show DNS-based routing
- Demonstrate failover by cordoning a cluster

## 📚 References

- [AKS Fleet Manager Documentation](https://learn.microsoft.com/en-us/azure/kubernetes-fleet/)
- [KubeFleet CNCF Project](https://kubefleet.dev)
- [Azure CLI Fleet Extension](https://learn.microsoft.com/en-us/cli/azure/fleet)
