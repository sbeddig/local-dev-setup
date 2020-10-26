#!/usr/bin/env bash

set -eou pipefail

UNSEAL_KEYS_FILE="$HOME/.localdev/vault/keys/unseal-keys"

unseal_keys=$(cat "$UNSEAL_KEYS_FILE")
for key in $unseal_keys; do
  vault operator unseal -tls-skip-verify "$key"
done