# Reference Infrastructure Fabric

Bootstrapping a microservices system is often a very difficult process for many small teams because there is a diverse ecosystem of tools that span a number of technical disciplines from operations to application development. This repository is intended for a single developer on a small team that meets all of the following criteria:

1. Building a simple modern web application using a service-oriented or microservices approach.

2. Using Amazon Web Services ("AWS") because of its best-in-class commodity "run-and-forget" infrastructure such as RDS MySQL, PostgreSQL, Elasticsearch or Redis.

3. Limited operations experience or budget and wants to "get going quickly" but with a reasonably architected foundation that will not cause major headaches two weeks down the road because the foundation "was just a toy".

If all the above criteria match then this project is for you and you should keep reading!

## What do you mean by "simple modern web application"?

### Simple

The concept of simplicity is a subjective, but for the purpose of this architecture "simple" means that the application conforms to two constraints:

1. Business logic, for example, a REST API is containerized and run on the Kubernetes fabric.
2. Persistence is offloaded into an external system.

### Modern

Similarly the term "modern" is ambiguous, but for the purpose of this architecture "modern" means that the application has a very narrow downtime constraint. We will be targetting an application that is designed for at least "four nines" of availability. Practically speaking, this means the app can be updated or modified without downtime.

## Technical Design in Five Minutes

**NOTE**: More advanced documentation is available in the [docs/](docs/) directory.

## Getting Started

### Prerequisites

1. You need an active AWS account and a AWS API credentials. Please read our five-minute "Bootstrapping AWS" guide if you do not have this yet.

2. Install Hashicorp's [Terraform](https://terraform.io).

3. Install Kubernetes Ops ("kops") tool.

### Sanity Checking

Run the script `bin/sanity` to check that everything is OK for deployment.

### Clone Repository

Clone this repository into your own account or organization.

## Next Steps

Check out Datawire's Reference Application - Snackchat! 

## License

Project is open-source software licensed under **Apache 2.0**. Please see [LICENSE](LICENSE) for more information.
