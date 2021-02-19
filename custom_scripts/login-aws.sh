#!/usr/bin/env bash

set -euo pipefail

ACCOUNT_ID=$1
TOTP=$2

ROLE_ARN=arn:aws:iam::$ACCOUNT_ID:role/custom-admin-role
ROLE_SESSION=admin-access
MFA_DEVICE=arn:aws:iam::$ACCOUNT_ID:mfa/mfa_user

credentials=$(aws sts assume-role \
  --role-arn "$ROLE_ARN" \
  --role-session-name $ROLE_SESSION \
  --serial-number "$MFA_DEVICE" \
  --token-code "$TOTP" \
  --duration-seconds 3600 \
  --profile mfa)

aws configure set region eu-west-1 --profile totp
aws configure set cli_pager "" --profile totp
aws configure set output json --profile totp
aws configure set aws_access_key_id "$(echo "$credentials" | jq -r '.Credentials | .AccessKeyId')" --profile totp
aws configure set aws_secret_access_key "$(echo "$credentials" | jq -r '.Credentials | .SecretAccessKey')" --profile totp
aws configure set aws_session_token "$(echo "$credentials" | jq -r '.Credentials | .SessionToken')" --profile totp

echo "login to aws successfully."

