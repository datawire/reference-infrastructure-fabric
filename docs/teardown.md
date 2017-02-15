# Destroy a Fabric

Tearing down a Fabric is very easy and is two steps:

1. Terminate the Kubernetes cluster.
2. Terminate any provisioned infrastructure and the underlying network.

## Danger Will Robinson! Danger!

Destroying a fabric cannot be undone! All running systems including data storage will be wiped from existence **in that fabric only**! You have been warned!

## Procedure

Each instructions assumes you're starting from the root directory of the repository:

1. Teardown the Kubernetes cluster:

    ```bash
    export CLUSTER_NAME="$(terraform output cluster_fqdn | tr -d '\n')"
 
    cd cluster/
    terraform plan -var-file=../config.json -destroy -out plan-destroy.out
    terraform apply plan-destroy.out
 
    kops delete cluster --yes \
      --name=$(CLUSTER_NAME)
    ````

2. Teardown the infrastructure fabric:
    
    ```bash
    terraform plan -var-file=../config.json -destroy -out plan-destroy.out
    terraform apply plan-destroy.out
    ````    