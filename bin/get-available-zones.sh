#!/usr/bin/env bash

aws ec2 describe-availability-zones \
    --filters 'Name=state,Values=available' \
    --output json \
    --query 'AvailabilityZones[:3].ZoneName' \
    --region=$1