// file: main.tf

// ---------------------------------------------------------------------------------------------------------------------
// Networking
// ---------------------------------------------------------------------------------------------------------------------

module "main_network" {
  source             = "modules/vpc"
  cidr_block         = "${var.vpc_cidr}"
  name               = "${var.vpc_name}"
  internal_subnets   = ["${var.internal_subnets}"]
  external_subnets   = ["${var.external_subnets}"]
  availability_zones = ["${var.availability_zones}"]
}

// ---------------------------------------------------------------------------------------------------------------------
// DNS
// ---------------------------------------------------------------------------------------------------------------------

resource "aws_route53_zone" "main" {
  name          = "${var.domain_name}"
  comment       = "DNS zone for internal systems"
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
