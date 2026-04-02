# Scenario 2: Resource Propagation

Demonstrates deploying the Fleet Dashboard app from the hub cluster to member clusters using ClusterResourcePlacement.

## Connect to Hub Cluster

```bash
RG=$(terraform -chdir=../terraform output -raw resource_group_name)
FLEET=$(terraform -chdir=../terraform output -raw fleet_name)

az fleet get-credentials --resource-group $RG --name $FLEET
```

## Deploy App to Hub

```bash
kubectl apply -f ../app/k8s/namespace.yaml
kubectl apply -f ../app/k8s/deployment.yaml
kubectl apply -f ../app/k8s/service.yaml
```

## Create ClusterResourcePlacement

```bash
# Deploy to production clusters only
kubectl apply -f ../app/k8s/crp.yaml
```

## Monitor Propagation

```bash
kubectl get clusterresourceplacement deploy-fleet-dashboard -o yaml
```

## Verify on Member Clusters

```bash
# Switch to prod cluster
az aks get-credentials --resource-group $RG --name $(terraform -chdir=../terraform output -raw prod_cluster_name)
kubectl get pods -n fleet-demo
kubectl get svc -n fleet-demo
```

## Expand to All Clusters

Edit `crp.yaml` to use `PickAll` without label filters, then reapply.
