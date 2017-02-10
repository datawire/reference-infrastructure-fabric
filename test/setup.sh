#!/usr/bin/env bash
set -euo pipefail

TF_ARCH="linux_amd64"
TF_VERSION="0.8.6"

# Check if Terraform needs to be installed or if it's already cached
if [[ "$(hash terraform >/dev/null 2>&1)" = 1 || "$(terraform version | tr -d '\n')" != "Terraform v$TF_VERSION" ]]; then
    mkdir -p /tmp/terraform

    wget https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_${TF_ARCH}.zip \
        -O /tmp/terraform/terraform_${TF_VERSION}_${TF_ARCH}.zip \

    if [[ -f ${HOME}/bin/terraform ]]; then
        rm -f ${HOME}/bin/terraform
    fi

    unzip /tmp/terraform/terraform_${TF_VERSION}_${TF_ARCH}.zip -d ${HOME}/bin
    chmod +x ${HOME}/bin/terraform
fi

terraform version