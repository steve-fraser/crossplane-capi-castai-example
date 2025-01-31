helm repo add castai-helm https://castai.github.io/helm-charts
helm repo update
kubectl create ns castai-agent
helm upgrade -i cluster-controller castai-helm/castai-cluster-controller -n castai-agent \
  --set castai.apiKey="" \
  --set castai.clusterIdSecretKeyRef.name=castai-clusterid \
  --set castai.clusterIdSecretKeyRef.key="attribute.cluster_id" 
helm upgrade -i castai-agent castai-helm/castai-agent -n castai-agent \
  --set apiKey="" \
  --set provider="eks" \
  --set createNamespace=false 