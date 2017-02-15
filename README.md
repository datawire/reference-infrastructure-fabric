# Reference Infrastructure Fabric

[![Build Status](https://travis-ci.org/datawire/reference-infrastructure-fabric.svg?branch=master)](https://travis-ci.org/datawire/reference-infrastructure-fabric)

Bootstrapping a microservices system is often a very difficult process for many small teams because there is a diverse ecosystem of tools that span a number of technical disciplines from operations to application development. This repository is intended for a single developer on a small team that meets all of the following criteria:

1. Building a simple modern web application using a service-oriented or microservices approach.

2. Using Amazon Web Services ("AWS") because of its best-in-class commodity "run-and-forget" infrastructure such as RDS Aurora, PostgreSQL, Elasticsearch or Redis.

3. Limited operations experience or budget and wants to "get going quickly" but with a reasonably architected foundation that will not cause major headaches two weeks down the road because the foundation "was just a toy".

If all the above criteria match then this project is for you and you should keep reading because this guide will help you get setup with a production-quality Kubernetes cluster on AWS in about 10 to 15 minutes!

## What do you mean by "simple modern web application"?

### Simple

The concept of simplicity is a subjective, but for the purpose of this architecture "simple" means that the application conforms to two constraints:

1. Business logic, for example, a REST API is containerized and run on the Kubernetes cluster.
2. Persistence is offloaded to an external service (e.g. Amazon RDS).

### Modern

Similarly the term "modern" is ambiguous, but for the purpose of this architecture "modern" means that the application has a very narrow downtime constraint. We will be targeting an application that is designed for at least "four nines" of availability. Practically speaking, this means the app can be updated or modified without downtime.

## What is an "Infrastructure Fabric"?

Infrastructure fabric is the term we use to describe the composite of a dedicated networking environment (VPC), service cluster (Kubernetes), and any strongly associated resources that are used by services in the services cluster (e.g. RDS, Elasticache, Elasticsearch). 

## Technical Design in Five Minutes

**NOTE**: More in-depth documentation is available in [docs/](docs/).

To keep this infrastructure fabric simple, but also robust we are going to make some opinionated design decisions.

### Base Network (VPC)

A single new Virtual Private Cloud ("VPC") will be created in a single region (us-east-2 "Ohio") that holds the Kubernetes cluster along with all long-lived systems (e.g. databases). A VPC is a namespace for networking. It provides strong network-level isolation from other "stuff" running in an AWS account. It's a good idea to create a separate VPC rather than relying on the default AWS VPC because over time the default VPC becomes cluttered and hard to maintain or keep configured properly with other systems and VPC's are a cost-free abstraction in AWS.

### Subnets

The VPC will be segmented into several subnets that are assigned to at least three availability zones ("AZ") within the region. An availability zone in AWS is a physically isolated datacenter within a region that has high-performance networking links with the other AZ's in the *same* region. The individual subnets will be used to ensure that both the Kubernetes cluster as well as any other systems such as an RDS database can be run simultaneously in at least two availability zones to ensure there is some robustness in the infrastructure fabric in case one AZ fails.

The deployed network fabric will not have an external vs. internal subnet distinction to avoid NAT gateways.

### DNS

Before the Kubernetes cluster can be provisioned a public DNS record in AWS Route 53 needs to exist, for example, at [Datawire](https://datawire.io) we own the mysterious `k736.net`. It is **strongly** recommended that you buy a domain name for this part of your infrastructure and do not use an existing one.

### Kubernetes

A Kubernetes cluster will be installed into the newly created VPC and setup with a single master node and several worker nodes spanning three availability zones. Despite the single master node this is still a HA setup because the worker nodes which actually run Kubernetes pods are spread across several availability zones. In the rare but potential situation where the master node fails the Kubernetes system will continue to be available until the master is automatically replaced (the mechanics of this are documented in [docs/high_availability.md](docs/high_availability.md).

### Diagram

Here's a pretty graphical diagram of all the above information...

## Getting Started

### Prerequisites

**NOTE:** You really need all three of these tools. A future guide will simplify the requirements to get setup but we want this to be a fairly vanilla introduction to using Kubernetes with AWS.

1. An active AWS account and a AWS API credentials. Please read our five-minute [AWS Bootstrapping](docs/aws_bootstrap.md) guide if you do not have an AWS account or AWS API credentials.

2. Install the following third-party tools.

| Tool                                                                       | Description                          |
| ---------------------------------------------------------------------------| ------------------------------------ |
| [AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html) | AWS command line interface           |
| [Terraform](https://terraform.io)                                          | Infrastructure provisioning tool     | 
| [Kubectl](https://kubernetes.io/docs/user-guide/prereqs/)                  | Kubernetes command line interface    |
| [kops](https://github.com/kubernetes/kops/releases)                        | Kubernetes cluster provisioning tool |

3. A domain name and hosted DNS zone in Route 53 that you can dedicate to the fabric, for example at [Datawire.io](https://datawire.io) we use `k736.net` which is meaningless outside of the company. This domain name will have several subdomains attached to it by the time you finish this guide. To get setup with Route 53 see the [Route53 Bootstrapping](docs/route53_bootstrap.md) guide.

### Clone Repository

Clone this repository into your own account or organization.

### Configure the Fabric name, DNS and availability zones

Every AWS account allocates a different set of availability zones that can be used within a region, for example, in `us-east-1` Datawire does not have access to the `us-east-1b` zone while other AWS accounts might. In order to ensure consistent deterministic runs of Terraform it is important to explicitly set the zones in the configuration.

A handy script [bin/get-available-zones.sh](bin/get-available-zones.sh) is provided that returns the zone information in the correct format to be copy and pasted into `config.json`.

Run:

```
# $REGION can be any of the AWS regions. 

bin/get-available-zones.sh $REGION
[
    "us-east-2a", 
    "us-east-2b", 
    "us-east-2c"
]
```

The returned JSON can be copied into `config.json` as the value of `fabric_availability_zones`. Make sure to also update the value of `fabric_region` with whatever you set `$REGION` to before running `bin/get-available-zones.sh`

Before the fabric can be provisioned two variables **MUST** be configured. The first is the name of the fabric and the second is the DNS name under which the fabric will be created. 

Open `config.json` and then find the `fabric_name` field and update it with an appropriate name. The name will be normalized to lowercase alphanumerics only so it is strongly recommended that you pick a name that makes sense once that is done.

Also find and update the `domain_name` field with a valid domain name that is owned and available in Route 53. 

### Sanity Checking

Automated sanity checking of both your local developer setup and your AWS account can be performed by running `bin/check_sanity` before continuing any further.

To run the sanity checker run the following command: `make sanity`. The sanity checker offers useful actionable feedback if it finds issues.

### Generate the AWS networking environment

The high-level steps to get the networking setup are:

1. Terraform generates a deterministic execution plan for the infrastructure it needs to create on AWS.
2. Terraform executes the plan and creates the necessary infrastructure.

Below are the detailed steps:

1. Run `terraform plan -var-file=config.json -out plan.out` and ensure the program exits successfully.
2. Run `terraform apply -var-file=config.json plan.out` and wait for Terraform to finish provisioning resources.

### Verify the AWS networking environment

TBD

### Push Terraform state into AWS S3

Terraform operates like a thermostat which means that it reconciles the desired world (`*.tf` files) with the provisioned world by computing a difference between a state file and the provisioned infrastructure. The provisioned resources are tracked in the system state file which maps actual system identifiers to resources described in the configuration templates users define (e.g. `vpc-abcxyz -> aws_vpc.kubernetes`). When Terraform detects a difference from the state file then it creates or updates the resource where possible (some things are immutable and cannot just be changed on-demand).

Terraform does not care where the state file is located so in theory it can be left on your local workstation, but a better option that encourages sharing and reuse is to push the file into Amazon S3 which Terraform natively knows how to handle.

To start we need to enable Terraform's remote state capabilities. Run the following command to begin:

```bash
terraform remote config \
  -backend=s3 \
  -backend-config="bucket=$(terraform output terraform_state_store_bucket | tr -d '\n')" \
  -backend-config="key=$(terraform output kubernetes_fqdn | tr -d '\n').tfstate" \
```

### Generate the Kubernetes cluster

The high-level steps to get the Kubernetes cluster setup are:

1. Ensure a public-private SSH key pair is generated for the cluster.
2. Invoke the `kops` too with some parameters that are output from the networking environment deployment.
3. Terraform generates a deterministic execution plan for the infrastructure it needs to create on AWS for the Kubernetes cluster.
4. Terraform executes the plan and creates the necessary infrastructure.
5. Wait for the Kubernetes cluster to deploy.

#### SSH public/private key pair

It is extremely unlikely you will need to SSH into the Kubernetes nodes, however, it's a good best practice to use a known or freshly-generated SSH key rather than relying on any tool or service to generate one. To generate a new key pair run the following command:

`ssh-keygen -t rsa -b 4096 -N '' -C "kubernetes-admin" -f "keys/kubernetes-admin"`

A 4096 bit RSA public and private key pair without a passphrase will be placed into the [/keys](/keys) directory. Move the private key out of this directory immediately after creation with the following command:

`mv keys/kubernetes-admin ~/.ssh/kubernetes-admin`

#### Invoke Kops to generate the Terraform template for Kubernetes

Kops takes in a bunch of parameters and generates a Terraform template that can be used to create a new cluster. The below command only generates the Terraform template it does not affect your existing infrastructure.

```bash
kops create cluster \
    --zones="$(terraform output main_network_availability_zones_csv | tr -d '\n')" \
    --vpc="$(terraform output main_network_id | tr -d '\n')" \
    --network-cidr="$(terraform output main_network_cidr_block | tr -d '\n')" \
    --networking="kubenet" \
    --ssh-public-key='keys/kubernetes-admin.pub' \
    --target="terraform" \
    --name="$(terraform output kubernetes_fqdn)" \
    --out=kubernetes
```

#### Plan and Apply the Kubernetes cluster with Terraform

Below are the detailed steps:

1. Run `terraform plan -state=kubernetes/terraform.tfstate -out kubernetes/plan.out kubernetes/` and ensure the program exits successfully.
2. Run `terraform apply -state=kubernetes/terraform.tfstate kubernetes/plan.out` and wait for Terraform to finish provisioning resources.

#### Push the Kubernetes Terraform state upto S3

TBD

#### Wait for the Kubernetes cluster to form

The Kubernetes cluster provisions asynchronously so even though Terraform exited almost immediately it's not likely that the cluster itself is running. To determine if the cluster is up you need to poll the API server. The script `bin/wait_up.py` provides a simple one line solution for this problem. 

## How much will this cost?

AWS is not free and so running this setup will incur some amount of monthly operational expense for you or your organization. The below table summarizes the expenses but **USER BEWARE** Datawire does not take any responsibility for the accuracy of these numbers. Also keep in mind your AWS bill will vary based on things such as bandwidth consumed and other AWS resources that you provision such as Amazon RDS instances.

### How can I make this cheaper?

There are really only straight forward strategies:

1. Use smaller EC2 instance sizes for the Kubernetes masters and nodes.
2. Purchase EC2 reserved instances for the types of nodes you know you need.

Other options exist such as EC2 spot instances or refactoring your application to be less resource intensive but those topics are outside the scope of this guide.

## Next Steps

### Add an RDS PostgreSQL database into the Fabric and access it from Kubernetes!

Coming Soon!

### Check out Datawire's Reference Application - Snackchat! 

Coming Soon!

## License

Project is open-source software licensed under **Apache 2.0**. Please see [LICENSE](LICENSE) for more information.
