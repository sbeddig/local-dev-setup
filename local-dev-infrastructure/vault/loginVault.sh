#!/usr/bin/env bash

set -eou pipefail

ROOT_TOKEN_FILE="$HOME/.localdev/vault/keys/root-token"

export VAULT_CACERT="$HOME/.localdev/vault/certs/vault-ca.crt"
vault login token="$(cat "$ROOT_TOKEN_FILE")"