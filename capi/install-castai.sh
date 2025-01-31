helm repo add castai-helm https://castai.github.io/helm-charts
helm repo update
kubectl create ns castai-agent
helm upgrade -i cluster-controller castai-helm/castai-cluster-controller -n castai-agent \
  --set castai.apiKey="$CAST_API_KEY" \
  --set castai.clusterIdSecretKeyRef.name=castai-clusterid \
  --set castai.clusterIdSecretKeyRef.key="CLUSTER_ID" 
helm upgrade -i castai-agent castai-helm/castai-agent -n castai-agent \
  --set apiKey="$CAST_API_KEY" \
  --set provider="eks" \
  --set createNamespace=false 