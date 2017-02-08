# Reference Infrastructure Fabric

Bootstrapping a microservices system is often a very difficult process for many small teams because there is a diverse ecosystem of tools that span a number of technical disciplines from operations to application development. This repository is intended for a single developer on a small team that meets all of the following criteria:

1. Building a simple modern web application using a service-oriented or microservices approach.

2. Using Amazon Web Services ("AWS") because of its best-in-class commodity "run-and-forget" infrastructure such as RDS Aurora, PostgreSQL, Elasticsearch or Redis.

3. Limited operations experience or budget and wants to "get going quickly" but with a reasonably architected foundation that will not cause major headaches two weeks down the road because the foundation "was just a toy".

If all the above criteria match then this project is for you and you should keep reading!

## What do you mean by "simple modern web application"?

### Simple

The concept of simplicity is a subjective, but for the purpose of this architecture "simple" means that the application conforms to two constraints:

1. Business logic, for example, a REST API is containerized and run on the Kubernetes cluster.
2. Persistence is offloaded into an external system.

### Modern

Similarly the term "modern" is ambiguous, but for the purpose of this architecture "modern" means that the application has a very narrow downtime constraint. We will be targetting an application that is designed for at least "four nines" of availability. Practically speaking, this means the app can be updated or modified without downtime.

## Technical Design in Five Minutes

**NOTE**: More in-depth documentation is available in [docs/](docs/).

To keep this infrastructure fabric simple, but also robust we are going to make some opinionated design decisions.

### Base Network (VPC)

A single new Virtual Private Cloud ("VPC") will be created in a single region (us-east-2 "Ohio") that holds the Kubernetes cluster along with all long-lived systems (e.g. databases). A VPC is a namespace for networking. It provides strong network-level isolation from other "stuff" running in an AWS account. It's a good idea to create a separate VPC rather than relying on the default AWS VPC because over time the default VPC becomes cluttered and hard to maintain or keep configured properly with other systems and VPC's are a cost-free abstraction in AWS.

### Subnets

The VPC will be segmented into several subnets that are assigned to at least three availability zones ("AZ") within the region. An availability zone in AWS is a physically isolated datacenter within a region that has high-performance networking links with the other AZ's in the *same* region. The individual subnets will be used to ensure that both the Kubernetes cluster as well as any other systems such as an RDS database can be run simultaneously in at least two availability zones to ensure there is some robustness in the infrastructure fabric in case one AZ fails.

The deployed network fabric will not have an external vs. internal subnet distinction to avoid NAT gateways.

### DNS

**NOTE:** Explore creative ways to make this not suck.

Before the Kubernetes cluster can be provisioned a public DNS record in AWS Route 53 needs to exist, for example, at [Datawire](https://datawire.io) we own the mysterious `k736.net`. It is **strongly** recommended that you buy a domain name for this part of your infrastructure and do not use an existing one.

### Kubernetes

A Kubernetes cluster will be installed into the newly created VPC and setup with a single master node and several worker nodes spanning three availability zones. Despite the single master node this is still a HA setup because the worker nodes which actually run Kubernetes pods are spread across several availability zones. In the rare but potential situation where the master node fails the Kubernetes system will continue to be available until the master is automatically replaced (the mechanics of this are documented in [docs/high_availability.md](docs/high_availability.md).

### Diagram

Here's a pretty graphical diagram of all the above information...

## Getting Started

### Prerequisites

1. You need an active AWS account and a AWS API credentials. Please read our five-minute [AWS Bootstrapping](docs/aws_bootstrap.md) guide if you do not have an AWS account or AWS API credentials.

2. You need to install the following third-party tools. You can perform this manually or run `bin/setup-required-tools`:

| Tool                              | Description                           |
| --------------------------------- | ------------------------------------- |
| [Terraform](https://terraform.io) | Infrastructure provisioning tool. | 
| [Kubectl](https://example.org)    | Kubernetes CLI |
| [kops](https://example.org)       | Kubernetes Ops ("kops") |

### Clone Repository

Clone this repository into your own account or organization.

### Set your Domain Name

Update the `terraform.tfvars.json` file by finding the `domain_name` key and updating it with the value of the domain name you purchased. 

### Sanity Checking

Automated sanity checking of both your local developer setup and your AWS account can be performed by running `bin/check_sanity` before continuing any further.

To run the sanity checker run the following command: `make sanity`. The sanity checker offers useful actionable feedback if it finds issues.

### Generate the AWS networking environment

The basic outline to get the networking setup is:

1. Terraform generates a deterministic execution plan for the infrastructure it needs to create on AWS.
2. Terraform executes the plan and creates the necessary infrastructure.

... Detail Instructions TBD ...

### Verify the AWS networking environment

### Generate the Kubernetes cluster configuration

### Generate the Kubernetes cluster

## Next Steps

Check out Datawire's Reference Application - Snackchat! 

## License

Project is open-source software licensed under **Apache 2.0**. Please see [LICENSE](LICENSE) for more information.
