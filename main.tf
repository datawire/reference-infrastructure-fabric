// file: main.tf

provider "aws" {
  region = "${var.fabric_region}"
}

// ---------------------------------------------------------------------------------------------------------------------
// Networking
// ---------------------------------------------------------------------------------------------------------------------

module "main_network" {
  source                  = "modules/vpc"
  cidr_block              = "${var.vpc_cidr}"
  name                    = "${var.fabric_name}"
  internal_subnets        = ["${var.internal_subnets}"]
  external_subnets        = ["${var.external_subnets}"]
  availability_zones      = ["${var.fabric_availability_zones}"]
}

// ---------------------------------------------------------------------------------------------------------------------
// DNS
//
// TODO: Modularize
// ---------------------------------------------------------------------------------------------------------------------

resource "aws_route53_zone" "main" {
  name          = "${var.domain_name}"
  comment       = "Global DNS zone for all fabric infrastructure"
  force_destroy = false
}

resource "aws_route53_zone" "kubernetes" {
  name          = "k8s.${var.domain_name}"
  comment       = "Child DNS zone for Kubernetes (k8s) clusters"
  force_destroy = false
}

resource "aws_route53_record" "main" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "k8s.${var.domain_name}"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.kubernetes.name_servers.0}",
    "${aws_route53_zone.kubernetes.name_servers.1}",
    "${aws_route53_zone.kubernetes.name_servers.2}",
    "${aws_route53_zone.kubernetes.name_servers.3}"
  ]
}

// ---------------------------------------------------------------------------------------------------------------------
// S3 buckets for Terraform and Kops
//
// TODO: Modularize
// ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "kops" {
  bucket = "${replace(var.domain_name, ".", "-")}-kops"
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "terraform" {
  bucket = "${replace(var.domain_name, ".", "-")}-terraform"
  acl    = "private"

  versioning {
    enabled = true
  }
}
