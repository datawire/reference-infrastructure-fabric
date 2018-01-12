# Reference Infrastructure Fabric

[![Build Status](https://travis-ci.org/datawire/reference-infrastructure-fabric.svg?branch=master)](https://travis-ci.org/datawire/reference-infrastructure-fabric)

**Set up a production-quality Kubernetes cluster on AWS in 15 minutes**

Bootstrapping a microservices system is often a very difficult process for many small teams because there is a diverse ecosystem of tools that span a number of technical disciplines from operations to application development. This repository is intended for a single developer on a small team that meets the following criteria:

1. Building a simple modern web application using a service-oriented or microservices approach.

2. Using Amazon Web Services ("AWS") because of its best-in-class commodity "run-and-forget" infrastructure, such as RDS Aurora, PostgreSQL, Elasticsearch, or Redis.

3. Limited operations experience or budget and wants to "get going quickly" but with a reasonably architected foundation that will not cause major headaches two weeks down the road because the foundation "was just a toy."

If the above criteria match then this project is for you and you should keep reading because this guide will help you get set up with a production-quality Kubernetes cluster on AWS in about 10 to 15 minutes!

## What do you mean by "simple modern web application?"

### Simple

The concept of simplicity is subjective, but for the purpose of this architecture "simple" means that the application conforms to two constraints:

1. Business logic, for example, a REST API, is containerized and runs on the Kubernetes cluster.
2. Persistence is offloaded to an external service (e.g. Amazon RDS).

### Modern

Similarly, the term "modern" is ambiguous, but for the purpose of this architecture "modern" means that the application has a very narrow downtime constraint. We will be targeting an application that is designed for at least "four nines" of availability. Practically speaking, this means the app can be updated or modified without downtime.

## What is an "Infrastructure Fabric"?

Infrastructure fabric is the term we use to describe the composite of a dedicated networking environment (VPC, more below), container cluster (Kubernetes), and any strongly associated resources that are used by services in the container cluster (e.g. RDS, Elasticache, Elasticsearch).

## Technical Design in Five Minutes

To keep this infrastructure fabric simple, but also robust, we are going to make some opinionated design decisions.

### Repository Structure

The GitHub repository is set up so that each fabric is defined in an independent Git branch. This allows for multiple fabrics to exist in parallel and for concurrent modification of the fabrics. Why might you want multiple fabrics? It allows multiple environments, e.g., develop, test, staging, prod. It also enables other types of useful separation, for example, Alice and Bob can each have their own cloud-deployed fabrics for whatever purpose they need. For simplicity, fabrics are named with DNS-compatible names.

### Base Network (VPC)

A single new Virtual Private Cloud ("VPC") will be created in a single AWS region (us-east-2 "Ohio") that holds the Kubernetes cluster along with all long-lived systems (e.g., databases). A VPC is a namespace for networking. It provides strong network-level isolation from unrelated stuff running in an AWS account. It's a good idea to create a separate VPC rather than relying on the default AWS VPC. Over time, the default VPC becomes cluttered and hard to maintain or keep configured properly with other systems. Also, VPCs are a cost-free abstraction in AWS. The base network will be IPv4 because Kubernetes does not run on IPv6 networks yet.

### Subnets

The VPC will be segmented into several subnets that are assigned to at least three availability zones ("AZ") within the region. An availability zone in AWS is a physically-isolated datacenter within an AWS region that has high-performance networking links with the other AZ's in the *same* region. The individual subnets will be used to ensure that both the Kubernetes cluster as well as any other systems, such as an RDS database, can be run simultaneously in at least two availability zones to ensure there is some robustness in the infrastructure fabric in case one AZ fails.

The deployed network fabric will not have an external vs. internal subnet distinction to avoid NAT gateways.

### DNS

Before the Kubernetes cluster can be provisioned, a public DNS record in AWS Route 53 needs to exist. For example, at [Datawire](https://datawire.io), we own the mysterious `k736.net`. It is **strongly** recommended that you buy a domain name for this part of your infrastructure and do not use an existing one.

### Kubernetes

A Kubernetes cluster is created in the new VPC and set up with a master node per availability zone and then the worker nodes (sometimes called "kubelets" or "minions" on the internet for historical reasons) are created across the availability zones as well. This design provides a high availability ("HA") cluster.



## Getting Started

### 0. Prerequisites

You'll need all of the following to get through the guide. We'll go into more detail on how to set everything up in later sections.

1. An active AWS account and AWS API credentials.

2. A domain name and hosted DNS zone in AWS Route 53 that you can dedicate to the fabric. This domain name will have several subdomains attached to it by the time you finish this guide.

3. All of the following third-party tools

| Tool                                                                       | Description                          |
| ---------------------------------------------------------------------------| ------------------------------------ |
| [AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html) | AWS command line interface           |
| `bash`                                                                     | Popular shell on *Nix. So popular you probably already have it! |
| [Terraform v0.8.8](https://www.terraform.io/intro/getting-started/install.html)   | Infrastructure provisioning tool     |
| [Kubectl](https://kubernetes.io/docs/user-guide/prereqs/)                  | Kubernetes command line interface    |
| [kops](https://github.com/kubernetes/kops/releases)                        | Kubernetes cluster provisioning tool |
| [Python](https://www.python.org/) >= 3.4                                   | Popular scripting language. Python is used for some utility scripts in [bin/](bin/) |

**NOTE:** You really need all of these tools. A future guide will simplify the requirements to get set up.

### 1. Install third-party tools

Follow the links below for information on installing each tool.

- [AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
- [Terraform](https://www.terraform.io/intro/getting-started/install.html)
- [Kubectl](https://kubernetes.io/docs/user-guide/prereqs/)
- [kops](https://github.com/kubernetes/kops/releases)
- [Python](https://www.python.org/) >= 3.4

### 2. Bootstrap AWS

Before we begin a couple things need to be done on the AWS account.

1. Get an AWS IAM user and API credentials. Follow [Bootstrapping AWS](docs/aws_bootstrap.md) for instructions on setting up an AWS user or skip this step if you already have a user setup.

2. Get a domain name for use with the fabric. Follow [Bootstrapping Route 53](docs/route53_bootstrap.md) for instructions on setting up Route 53 properly or skip this step if you already have a domain setup.

### 3. Clone Repository

Clone this repository into your own account or organization. The cloned repository contains two branches: `master` and `fabric/example`. The `master` branch contains documentation and some specialized scripts for bootstrapping AWS and additional fabrics. The `fabric/example` branch is an example repository that is nearly ready for use.

### 4. Checkout the example branch then overlay the master branch tools onto it

The repository is setup as a monorepo that uses branches to keep environment definitions independent. Run the following commands to get where you want to be:

1. `git pull`
2. `git checkout fabric/example`
3. `git checkout master -- bin/`

After running those commands you should be in the `example/fabric` branch and the tools from the [bin/](bin/) directory on the `master` branch will be available for use.

### 5. Configure the Fabric name, DNS, region and availability zones

Every AWS *account* is allocated a different set of availability zones that can be used within a region. For example, in the `us-east-1` region, Datawire does not have access to the `us-east-1b` zone while other AWS accounts might. In order to ensure consistent deterministic runs of Terraform, it is important to set the zones in the configuration explicitly.

For this guide, we're going to assume `us-east-2` is your preferred deployment region.

A useful script [bin/configure_availability_zones.py](bin/configure_availability_zones.py) is provided that will automatically update [config.json](config.json) with appropriate values. Run the script as follows.

```
bin/configure_availability_zones.py us-east-2
```

After a moment you should see the following message:

```
Updating config.json...
    Region             = us-east-2
    Availability Zones = ['us-east-2a', 'us-east-2b', 'us-east-2c']

Done!
```

You can confirm the operation was successful by comparing the above with the values in `config.json`:

```
cat config.json
{
    "domain_name": "${YOUR_DOMAIN_HERE}",
    "fabric_availability_zones": [
        "us-east-2a",
        "us-east-2b",
        "us-east-2c"
    ],
    "fabric_name": "example",
    "fabric_region": "us-east-2"
}
```

Two other variables must be configured in `config.json` before the fabric can be provisioned. The first is the name of the fabric and the second is the DNS name under which the fabric will be created.

Open `config.json` and then update the `fabric_name` field with a DNS-compatible name. The name will be normalized to lowercase alphanumeric characters only so it is strongly recommended that you pick a name that makes sense once that is done.

Also, find and update the `domain_name` field with a valid domain name that is owned and available in Amazon Route 53.

### 6. Create S3 bucket for Terraform and Kubernetes state storage

Terraform operates like a thermostat, which means that it reconciles the desired world (`*.tf` templates) with the provisioned world by computing a difference between a state file and the provisioned infrastructure. The provisioned resources are tracked in the system state file that maps actual system identifiers to resources described in the configuration templates users define (e.g., `vpc-abcxyz -> aws_vpc.kubernetes`). When Terraform detects a difference from the state file then it creates or updates the resource where possible (some things are immutable and cannot just be changed on-demand).

Terraform does not care where the state file is located so, in theory, it can be left on your local workstation, but a better option that encourages sharing and reuse is to push the file into Amazon S3, which Terraform natively knows how to handle.

Run the command:

`bin/setup_state_store.py`

If the operation is successful it will return the name of the S3 bucket, which is the value of `config.json["domain_name"]` with `-state` appended and all nonalphanumeric characters replaced with `-` (dash) characters. For example:

```
cat config.json
{
    "domain_name": "k736.net"
}

bin/setup_state_store.py
Bucket: k736-net-state
```

### 7. Generate the AWS networking environment

The high-level steps to get the networking set up are:

1. Terraform generates a deterministic execution plan for the infrastructure it needs to create on AWS.
2. Terraform executes the plan and creates the necessary infrastructure.

Below are the detailed steps:

1. Configure Terraform to talk to the remote state store:

  ```bash
  terraform remote config \
      -backend=s3 \
      -backend-config="region=us-east-2" \
      -backend-config="bucket=$(bin/get_state_store_name.py)" \
      -backend-config="key=$(bin/get_fabric_name.py).tfstate"
  ```

2. Run `terraform get -update=true`

3. Run `terraform plan -var-file=config.json -out plan.out` and ensure the program exits successfully.
4. Run `terraform apply plan.out` and wait for Terraform to finish provisioning resources.

### 8. Generate the Kubernetes cluster

The high-level steps to get the Kubernetes cluster setup are:

1. Ensure a public-private SSH key pair is generated for the cluster.
2. Invoke the `kops` tool with some parameters that are output from the networking environment deployment.
3. Terraform generates a deterministic execution plan for the infrastructure it needs to create on AWS for the Kubernetes cluster. Then Terraform executes the plan and creates the necessary infrastructure.
4. Wait for the Kubernetes cluster to deploy.

#### 8.1 SSH public/private key pair

It is extremely unlikely you will need to SSH into the Kubernetes nodes, however, it is a good best practice to use a known or freshly-generated SSH key rather than relying on any tool or service to generate one. To generate a new key pair run the following command:

`ssh-keygen -t rsa -b 4096 -N '' -C "kubernetes-admin" -f "keys/kubernetes-admin"`

A 4096-bit RSA public and private key pair without a passphrase will be placed into the [/keys](/keys) directory. Move the private key out of this directory immediately after creation with the following command:

`mv keys/kubernetes-admin ~/.ssh/kubernetes-admin`

Ensure you the private key is read/write only by your user as well:

`chmod 600 ~/.ssh/kubernetes-admin`

#### 8.2 Invoke Kops to generate the Terraform template for Kubernetes

Kops takes in a bunch of parameters and generates a Terraform template that can be used to create a new cluster. The next command only generates the Terraform template; it does not affect your existing infrastructure.

```bash
kops create cluster \
    --zones="$(terraform output main_network_availability_zones_csv | tr -d '\n')" \
    --vpc="$(terraform output main_network_id | tr -d '\n')" \
    --network-cidr="$(terraform output main_network_cidr_block | tr -d '\n')" \
    --networking="kubenet" \
    --ssh-public-key='keys/kubernetes-admin.pub' \
    --target="terraform" \
    --name="$(bin/get_fabric_fqdn.py)" \
    --state="s3://$(bin/get_state_store_name.py)" \
    --out=kubernetes
```

#### 8.3 Plan and Apply the Kubernetes cluster with Terraform

Below are the detailed steps:

1. Run `cd kubernetes/`

2. Configure Terraform to talk to the remote state store:

  ```bash
  terraform remote config \
      -backend=s3 \
      -backend-config="region=us-east-2" \
      -backend-config="bucket=$(cd .. && bin/get_state_store_name.py)" \
      -backend-config="key=$(cd .. && bin/get_fabric_name.py)-kubernetes.tfstate"
  ```

3. Run `terraform get -update=true`
4. Run `terraform plan -out plan.out` and ensure the program exits successfully.
5. Run `terraform apply plan.out` and wait for Terraform to finish provisioning resources.

#### 8.4 Wait for the Kubernetes cluster to form

The Kubernetes cluster provisions asynchronously so even though Terraform exited almost immediately it's not likely that the cluster itself is running. To determine if the cluster is up you need to poll the API server. You can do this by running `kubectl cluster-info`, which will eventually return the API server address.

### How can I make this cheaper?

Here are two straightforward strategies:

1. Use smaller EC2 instance sizes for the Kubernetes masters and nodes.

    ```bash
    kops create cluster \
        --master-size=t2.nano --node-size=t2.nano \
      [ ... ]
    ```

2. Purchase EC2 reserved instances for the types of nodes you know you need.

Other options exist such as EC2 spot instances or refactoring your application to be less resource intensive, but those topics are outside the scope of this guide.



## Next Steps

### Add an RDS PostgreSQL database into the Fabric and access it from Kubernetes!

Coming Soon!

### Check out Datawire's Reference Application - Snackchat!

Coming Soon!

## FAQ

**Q:** Why did you write this guide?

**A:** We use this guide to run Kubernetes clusters at Datawire and we thought it was useful information that other developers would find useful!

**Q:** How do I delete a fabric?

**A:** Check out the [Tearing down a Fabric](docs/destroy_fabric.md) document. It's very straightforward.


## License

This project is open-source software licensed under **Apache 2.0**. Please see [LICENSE](LICENSE) for more information.
