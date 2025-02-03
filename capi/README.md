# CAPI Example

## First install Crossplane
```
bash  1-install-crossplane.sh
```

## Install Cluster API for AWS if you have not already
[Getting Started with Cluster API for AWS](https://cluster-api-aws.sigs.k8s.io/getting-started)


## Install the CAST AI Crossplane porvider

### Generate a CAST AI API Key
```
export CAST_API_KEY=<>
```

### Install the CAST AI provider and configure it with your API key. Replace `<your-api-key>` with your actual CAST AI API key.

```
kubectl apply -f- <<EOF
---
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: crossplane-provider-castai
spec:
  package: xpkg.upbound.io/crossplane-contrib/crossplane-provider-castai:v0.21.0
---
apiVersion: v1
kind: Secret
metadata:
  name: castai-creds
  namespace: crossplane-system
type: Opaque
stringData:
  credentials: |
    {
      "api_token": $CAST_API_KEY,
      "api_url": "https://api.cast.ai"
    }
---
apiVersion: castai.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: castai-creds
      key: credentials
EOF
```