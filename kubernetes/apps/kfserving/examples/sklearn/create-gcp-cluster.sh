#!/bin/bash

NETWORK="yjkim-vpc"  # "default" or VPC
SUBNETWORK="yjkim-kube-subnet"

PROJECT_ID="ds-ai-platform"
CLUSTER_NM="kfserving-dev"
REGION="us-central1"
#ZONE="us-central1-a"
CLUSTER_VERSION="1.15.9-gke.24"
MASTER_IPV4_CIDR="192.168.1.32/28"
CLUSTER_IPV4_CIDR="10.0.0.0/14"  # The IP address range for the pods in this cluster
SERVICE_IPV4_CIDR="172.16.0.0/16"  # Set the IP range for the services IPs. Can be specified as a netmask size (e.g. '/20') or as in CIDR notion (e.g. '10.100.0.0/20').  Can not be specified unless '--enable-ip-alias' is also specified.
DISK_TYPE="pd-standard"  #  pd-standard, pd-ssd
DISK_SIZE="100GB"  # default: 100GB
IMAGE_TYPE="UBUNTU"  # COS, UBUNTU, COS_CONTAINERD, UBUNTU_CONTAINERD, WINDOWS_SAC, WINDOWS_LTSC (gcloud container get-server-config)
MACHINE_TYPE="n1-standard-4" # 4CPUs, 16GB (gcloud compute machine-types list) <https://cloud.google.com/compute/vm-instance-pricing>

# #--- [GPUs]: Check AZ for GPU model Availability <https://cloud.google.com/compute/docs/gpus#gpus-list> ---#
# # (gcloud compute accelerator-types list) ,count: default 1

# # 1. {Tesla T4: (us-central1-a, us-central1-b, us-central1-f), (asia-northeast3-b, asia-northeast3-c)}
# ACCELERATOR="type=nvidia-tesla-t4,count=1"
# ZONE_NODE_LOCATIONS="us-central1-a,us-central1-b,us-central1-f"

# # 2. {Tesla K80: (us-central1-a, us-central1-c)}
# ACCELERATOR="type=nvidia-tesla-k80,count=1"
# ZONE_NODE_LOCATIONS="us-central1-a,us-central1-c"

# # 3. {Tesla P100: (us-central1-c, us-central1-f)}
# ACCELERATOR="type=nvidia-tesla-p100,count=1"
# ZONE_NODE_LOCATIONS="us-central1-c,us-central1-f"

# # 4. {Tesla V100: (us-central1-a, us-central1-b, us-central1-c, us-central1-f)}
# ACCELERATOR="type=nvidia-tesla-v100,count=1"
# ZONE_NODE_LOCATIONS="us-central1-a,us-central1-b,us-central1-c,us-central1-f"

# #----------------------------------------------------------------------------------------------------------#
# Specifies the reservation for the default initial node pool.
# --reservation=RESERVATION
# The name of the reservation, required when --reservation-affinity=specific.
# --reservation-affinity=RESERVATION_AFFINITY
# The type of the reservation for the default initial node pool. RESERVATION_AFFINITY must be one of: any, none, specific.
#NODE_POOL="ubuntu-cpu"
NUM_NODES="2"  # The number of nodes to be created in each of the cluster's zones. default: 3
MIN_NODES="0"  # Minimum number of nodes in the node pool. Ignored unless `--enable-autoscaling` is also specified.
MAX_NODES="2" # Maximum number of nodes in the node pool. Ignored unless `--enable-autoscaling` is also specified.
MAX_NODES_PER_POOL="100"  # Defaults to 1000 nodes, but can be set as low as 100 nodes per pool on initial create.
MAX_PODS_PER_NODE="110"  # default=110, Must be used in conjunction with '--enable-ip-alias'.
NETWORK="yjkim-vpc"  # "default" or VPC
SUBNETWORK="yjkim-kube-subnet"
TAGS="yjkim-kube-instance,"  # (https://cloud.google.com/compute/docs/labeling-resources), tag1,tag2
SERVICE_ACCOUNT="yjkim-kube-admin-sa@ds-ai-platform.iam.gserviceaccount.com"

WORKLOAD_POOL="${PROJECT_ID}.svc.id.goog" # Enable Workload Identity on the cluster. When enabled, Kubernetes service accounts will be able to act as Cloud IAM Service Accounts, through the provided workload pool. Currently, the only accepted workload pool is the workload pool of the Cloud project containing the cluster, `PROJECT_ID.svc.id.goog.`
#--security-group=SECURITY_GROUP  # The name of the RBAC security group for use with Google security groups in Kubernetes RBAC (https://kubernetes.io/docs/reference/access-authn-authz/rbac/). If unspecified, no groups will be returned for use with RBAC.
ISTIO_CONFIG="auth=MTLS_PERMISSIVE"
METADATA="disable-legacy-endpoints=true"
LABELS="cz_owner=youngju_kim,application=kubeflow"
DESCRIPTION="A testbed Kubernetes cluster;for Kubeflow, KFServing, NVIDIA Runtime, etc."
SOURCE_NETWORK_CIDRS=""

gcloud beta container clusters create \
    $CLUSTER_NM \
    --region=$REGION \
    --cluster-version=$CLUSTER_VERSION \
    --enable-autoscaling \
    --min-nodes=$MIN_NODES \
    --max-nodes=$MAX_NODES \
    --enable-vertical-pod-autoscaling \
    --enable-ip-alias \
    --enable-private-nodes \
    --no-enable-master-authorized-networks \
    --master-ipv4-cidr=$MASTER_IPV4_CIDR \
    --cluster-ipv4-cidr=$CLUSTER_IPV4_CIDR \
    --services-ipv4-cidr=$SERVICE_IPV4_CIDR \
    --disk-type=$DISK_TYPE \
    --disk-size=$DISK_SIZE \
    --image-type=$IMAGE_TYPE \
    --machine-type=$MACHINE_TYPE \
    --num-nodes=$NUM_NODES \
    --max-nodes-per-pool=$MAX_NODES_PER_POOL \
    --max-pods-per-node=$MAX_PODS_PER_NODE \
    --network=$NETWORK \
    --subnetwork=$SUBNETWORK \
    --tags=$TAGS \
    --service-account=$SERVICE_ACCOUNT \
    --workload-pool=$WORKLOAD_POOL \
    --workload-metadata=GKE_METADATA \
    --shielded-integrity-monitoring \
    --enable-stackdriver-kubernetes \
    --enable-autorepair \
    --no-enable-autoupgrade \
    --enable-intra-node-visibility \
    --enable-shielded-nodes \
    --metadata=$METADATA \
    --labels=$LABELS \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing,Istio,CloudRun,ApplicationManager \
    --istio-config=$ISTIO_CONFIG \
    --scopes="gke-default"


# gcloud beta container clusters create \
#     $CLUSTER_NM \
#     --region=$REGION \
#     #--zone=$ZONE \
#     #--workload-pool=$WORKLOAD_POOL \
#     --cluster-version=$CLUSTER_VERSION \
#     --enable-autoscaling \
#     --min-nodes=$MIN_NODES \
#     --max-nodes=$MAX_NODES \
#     --enable-vertical-pod-autoscaling \
#     --enable-ip-alias \
#     #--enable-private-endpoint \
#     --enable-private-nodes \
#     --no-enable-master-authorized-networks \
#     # --enable-master-global-access \
#     # --enable-master-authorized-networks \
#     #   --master-authorized-networks=SOURCE_NETWORK_CIDRS \
#     --master-ipv4-cidr=$MASTER_IPV4_CIDR \
#     --cluster-ipv4-cidr=$CLUSTER_IPV4_CIDR \
#     --services-ipv4-cidr=$SERVICE_IPV4_CIDR \
#     --disk-type=$DISK_TYPE \
#     --disk-size=$DISK_SIZE \
#     --image-type=$IMAGE_TYPE \
#     --machine-type=$MACHINE_TYPE \
#     #--accelerator=ACCELERATOR \
#     #--node-locations=$ZONE_NODE_LOCATIONS \
#     --num-nodes=$NUM_NODES \
#     --max-nodes-per-pool=$MAX_NODES_PER_POOL \
#     --max-pods-per-node=$MAX_PODS_PER_NODE \
#     --network=$NETWORK \
#     --subnetwork=$SUBNETWORK \
#     --tags=$TAGS \
#     --service-account=$SERVICE_ACCOUNT \
#     --shielded-integrity-monitoring \
#     --enable-stackdriver-kubernetes \
#     --enable-autorepair \
#     --no-enable-autoupgrade \
#     --enable-intra-node-visibility \
#     --enable-shielded-nodes \
#     --metadata=$METADATA \
#     --labels=$LABELS \
#     --addons HorizontalPodAutoscaling,HttpLoadBalancing,Istio,CloudRun \
#     --istio-config=$ISTIO_CONFIG \
#     --scopes="gke-default"