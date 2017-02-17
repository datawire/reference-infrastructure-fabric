# Technical Design in Five Minutes

**NOTE**: More in-depth documentation is available in [docs/](docs/).

To keep this infrastructure fabric simple, but also robust we are going to make some opinionated design decisions.

### Repository Structure

The GitHub repository is setup so that each fabric is defined in an independent Git branch. This allows for multiple fabrics to exist in parallel and for concurrent modification of the fabrics. Why might you want multiple fabrics? A couple reasons, it allows multiple environments (e.g. develop, test, staging, prod) and it enables other types of useful separation, for example, Alice and Bob can have their own cloud-deployed fabrics for whatever purpose they need.

Fabrics are named 

### Base Network (VPC)

A single new Virtual Private Cloud ("VPC") will be created in a single region (us-east-2 "Ohio") that holds the Kubernetes cluster along with all long-lived systems (e.g. databases). A VPC is a namespace for networking. It provides strong network-level isolation from other "stuff" running in an AWS account. It's a good idea to create a separate VPC rather than relying on the default AWS VPC because over time the default VPC becomes cluttered and hard to maintain or keep configured properly with other systems and VPC's are a cost-free abstraction in AWS. The base network will be IPv4 because Kubernetes does not run on IPv6 networks yet.

### Subnets

The VPC will be segmented into several subnets that are assigned to at least three availability zones ("AZ") within the region. An availability zone in AWS is a physically isolated datacenter within a region that has high-performance networking links with the other AZ's in the *same* region. The individual subnets will be used to ensure that both the Kubernetes cluster as well as any other systems such as an RDS database can be run simultaneously in at least two availability zones to ensure there is some robustness in the infrastructure fabric in case one AZ fails.

The deployed network fabric will not have an external vs. internal subnet distinction to avoid NAT gateways.

### DNS

Before the Kubernetes cluster can be provisioned a public DNS record in AWS Route 53 needs to exist, for example, at [Datawire](https://datawire.io) we own the mysterious `k736.net`. It is **strongly** recommended that you buy a domain name for this part of your infrastructure and do not use an existing one.

### Kubernetes

A Kubernetes cluster is setup in the newly created VPC and setup with a master node per availability zone and then the worker nodes (**FYI**: sometimes called "kubelets" or "minions" on the internet because of historical reasons) are created across the availability zones as well. This design provides a high availability ("HA") cluster.
