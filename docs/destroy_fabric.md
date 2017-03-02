# Destroy a Fabric

Destroying a Fabric is very easy and is two steps:

1. Terminate the Kubernetes cluster.
2. Terminate any provisioned infrastructure and the underlying network.

## Danger Will Robinson! Danger!

Destroying a fabric cannot be undone! All running systems including data storage will be wiped from existence **in that fabric only**! You have been warned!

## Procedure

Each instructions assumes you're starting from the root directory of the repository:

1. Teardown the Kubernetes cluster:

    ```bash
    cd kubernetes/
    terraform plan -var-file=../config.json -destroy -out plan-destroy.out
    terraform apply plan-destroy.out

    kops delete cluster \
        --yes \
        --name="$(cd .. && bin/get_fabric_fqdn.py)" \
        --state="s3://$(cd .. && bin/get_state_store_name.py)"

    ```

    When all of these commands are completed then the Kubernetes cluster will be either completely shutdown or in a state of shutting down (EC2 instance shutdown is asynchronous). If you only want to teardown the Kubernetes cluster and not the rest of the fabric then **DO NOT RUN THE NEXT STEP**!

2. Teardown the infrastructure fabric:

    ```bash
    terraform plan -var-file=../config.json -destroy -out plan-destroy.out
    terraform apply plan-destroy.out
    ```
