// file: outputs.tf

output "kops_state_store_bucket"      { value = "${aws_s3_bucket.kops.id}" }
output "terraform_state_store_bucket" { value = "${aws_s3_bucket.terraform.id}" }