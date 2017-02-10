// file: outputs.tf

output "main_network_id"                     { value = "${module.main_network.id}" }
output "main_network_cidr_block"             { value = "${module.main_network.cidr_block}" }
output "main_network_availability_zones_csv" { value = "${join(",", module.main_network.availability_zones)}" }

output "kops_state_store_bucket"      { value = "${aws_s3_bucket.kops.id}" }
output "terraform_state_store_bucket" { value = "${aws_s3_bucket.terraform.id}" }

output "kubernetes_fqdn" { value = "${var.fabric_name}.${aws_route53_zone.kubernetes.name}" }