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

## Install the Kubernetes Provider 

This provider is used in the crossplane composition and will go into further details in the next section

```
kubectl apply -f 2-k8s-provider.yaml
```

## Install the composition

Install the composition

```
kubectl apply -f 3-composition.yaml
```


When invoked the composition looks like
```
apiVersion: test.com/v1alpha1
kind: EKSCluster
metadata:
  name: capi-eks-control-plane
spec:
  parameters:
    region: us-west-1
```

The inputs are defined [here](https://github.com/steve-fraser/crossplane-capi-castai-example/blob/main/capi/3-composition.yaml#L17-L29)

The composition uses the status field to pass subnets and security groups to the CAST AI node configuration as defined [here](https://github.com/steve-fraser/crossplane-capi-castai-example/blob/main/capi/3-composition.yaml#L30-L47)

The composition first creates an [AWSManagedControlPlane](https://github.com/steve-fraser/crossplane-capi-castai-example/blob/main/capi/3-composition.yaml#L61-L100) with a series of patches

It will find the subnets and security groups like and add them to the status field
```
    - type: ToCompositeFieldPath
      fromFieldPath: status.atProvider.manifest.spec.network.subnets[1].resourceID
      toFieldPath: status.subnetA
```

They will add them to the NodeConfiguration like this 

```
    - type: FromCompositeFieldPath
      fromFieldPath: status.subnetA
      toFieldPath: spec.forProvider.subnets[0]
```


Finally it will add the cluster id to a secret in the leaf cluster [like](https://github.com/steve-fraser/crossplane-capi-castai-example/blob/main/capi/3-composition.yaml#L141-L158)



## Apply the ClusterAPI manifests 
```
kubectl apply -f 5-castai-manifests.yaml
```


