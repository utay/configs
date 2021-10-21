#!/bin/sh

code="$1"

credentials=$(aws sts get-session-token --serial-number arn:aws:iam::382503283667:mfa/Yannick --token-code "$code" | jq .Credentials)
export AWS_ACCESS_KEY_ID=$(echo "$credentials" | jq -r .AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo "$credentials" | jq -r .SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo "$credentials" | jq -r .SessionToken)
export AWS_REGION=us-west-1
