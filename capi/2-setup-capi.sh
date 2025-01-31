export AWS_REGION=us-west-2 # This is used to help encode your environment variables
export AWS_ACCESS_KEY_ID=<>
export AWS_SECRET_ACCESS_KEY=<>

# The clusterawsadm utility takes the credentials that you set as environment
# variables and uses them to create a CloudFormation stack in your AWS account
# with the correct IAM resources.
curl -L https://github.com/kubernetes-sigs/cluster-api-provider-aws/releases/download/v1.4.1/clusterawsadm-linux-amd64 -o clusterawsadm
chmod +x clusterawsadm
sudo mv clusterawsadm /usr/local/bin/clusterawsadm

clusterawsadm bootstrap iam create-cloudformation-stack

# Create the base64 encoded credentials using clusterawsadm.
# This command uses your environment variables and encodes
# them in a value to be stored in a Kubernetes Secret.
export AWS_B64ENCODED_CREDENTIALS=$(clusterawsadm bootstrap credentials encode-as-profile)
export EKS=true
export EXP_MACHINE_POOL=true
export CAPA_EKS_IAM=true
# Finally, initialize the management cluster
clusterctl init --infrastructure aws


export AWS_CONTROL_PLANE_MACHINE_TYPE=t3.large
export AWS_NODE_MACHINE_TYPE=t3.large
export AWS_SSH_KEY_NAME=capi-ec2 
export AWS_REGION=us-west-2
export KUBERNETES_VERSION=1.30
clusterctl generate cluster capi-eks --flavor eks-managedmachinepool --worker-machine-count=2 > capi.yaml