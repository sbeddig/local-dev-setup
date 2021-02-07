#!/usr/bin/env bash

set -euo pipefail

ACCOUNT_ID=$1
TOTP=$2

ROLE_ARN=arn:aws:iam::$ACCOUNT_ID:role/custom-admin-role
ROLE_SESSION=admin-access
MFA_DEVICE=arn:aws:iam::$ACCOUNT_ID:mfa/mfa_user

aws sts assume-role \
  --role-arn "$ROLE_ARN" \
  --role-session-name $ROLE_SESSION \
  --serial-number "$MFA_DEVICE" \
  --token-code "$TOTP" \
  --duration-seconds 3600 \
  --profile mfa
