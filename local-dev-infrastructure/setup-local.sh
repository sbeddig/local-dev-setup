#!/usr/bin/env bash

set -eou pipefail

WORK_DIR=$PWD
VAULT_VERSION=1.4.1

if [ -z "$1" ]; then
 echo "Please specify concourse username"
 exit 1
fi

if [ -z "$2" ]; then
 echo "Please specify concourse password"
 exit 1
fi

CONCOURSE_USERNAME=$1
CONCOURSE_PASSWORD=$2

check_prerequisites() {
  if ! go version; then
    echo "Please install golang"
    exit 1
  fi
}

install_certstrap() {
  if ! certstrap --version; then
    git clone https://github.com/square/certstrap
    cd certstrap
    go build
    sudo mv certstrap /usr/local/bin/
    cd "$WORK_DIR"
    rm -rf certstrap
  fi
}

install_fly() {
  if ! fly -version; then
    ./concourse/fly/installFly.sh
  fi
}

install_vault_cli() {
  if ! vault -version; then
    wget --quiet --output-document=/tmp/vault.zip https://releases.hashicorp.com/vault/"${VAULT_VERSION}"/vault_"${VAULT_VERSION}"_linux_amd64.zip && \
    sudo unzip /tmp/vault.zip -d /usr/local/bin/ && \
    rm -f /tmp/vault.zip
  fi
}

stop_local_environment() {
  docker-compose down -v
}

generate_certificates() {
  if [ -d "$WORK_DIR/vault/vault-certs" ]; then
      echo "folder vault-certs already exists"
    else
      certstrap init --cn vault-ca

      certstrap request-cert --domain vault --ip 127.0.0.1
      certstrap sign vault --CA vault-ca

      certstrap request-cert --cn concourse
      certstrap sign concourse --CA vault-ca

      certstrap request-cert --cn registry
      certstrap sign registry --CA vault-ca

      mv out vault/vault-certs
  fi
}

generate_concourse_keys() {
  if [ -d "$WORK_DIR/concourse/keys/web" ]; then
      echo "concourse keys already exists"
    else
      mkdir -p "$WORK_DIR"/concourse/keys/web
      mkdir -p "$WORK_DIR"/concourse/keys/worker
      ./concourse/keys/generate
  fi
}

start_local_environment() {
  echo "CONCOURSE_USERNAME=$CONCOURSE_USERNAME" > .env
  echo "CONCOURSE_PASSWORD=$CONCOURSE_PASSWORD" >> .env

  docker-compose -p local-dev up -d --force-recreate --scale concourse-worker=2
}

print_urls() {
  echo "docker-registry : http://localhost:5000"
  echo "vault           : https://localhost:8200"
  echo "concourse-ci    : http://localhost:8080"
}

init_vault() {
  export VAULT_CACERT=$WORK_DIR/vault/vault-certs/vault-ca.crt
  init_json=$(vault operator init -format=json)
  mkdir -p "$WORK_DIR"/vault/vault-keys
  echo "$init_json" | jq -r '.unseal_keys_b64 | .[]' > "$WORK_DIR/vault/vault-keys/unseal-keys"
  echo "$init_json" | jq -r .root_token > "$WORK_DIR/vault/vault-keys/root-token"
}

unseal_vault() {
  unseal_keys=$(cat "$WORK_DIR/vault/vault-keys/unseal-keys")
  for key in $unseal_keys; do
    vault operator unseal "$key"
  done
}

configure_vault() {
  vault login token="$(cat "$WORK_DIR/vault/vault-keys/root-token")"

  vault policy write concourse-policy vault/policies/concourse-policy.hcl
  vault auth enable cert
  vault write auth/cert/certs/concourse \
    policies=concourse-policy \
    certificate=@vault/vault-certs/vault-ca.crt \
    ttl=1h
  vault secrets enable -version=1 -path=concourse kv
  vault kv put concourse/main/github-private-ssh-key -version=1 value="$(cat ~/.ssh/id_rsa)"
}

install_common() {
  sudo apt install unzip
}

copy_env_variables_to_local_folder() {
  rm -rf ~/.localdev/vault || true
  rm -rf ~/.localdev/concourse || true
  mkdir -p ~/.localdev/vault
  mkdir -p ~/.localdev/concourse
  mv vault/vault-keys ~/.localdev/vault/keys
  mv vault/vault-certs ~/.localdev/vault/certs
  mv .env ~/.localdev/concourse/keys
  cp vault/loginVault.sh  ~/.localdev/vault
  cp vault/unsealVault.sh ~/.localdev/vault
  touch ~/.localdev/env
  cat <<EOF | sudo tee -a ~/.localdev/env

docker-registry : http://localhost:5000
vault           : https://localhost:8200
concourse-ci    : http://localhost:8080

fly -t ci login --team-name main --concourse-url http://localhost:8080 --open-browser
vault kv put concourse/main/github-private-ssh-key -version=1 value="$(cat ~/.ssh/id_rsa)"

EOF

}

check_prerequisites
install_common
install_certstrap
install_fly
install_vault_cli
stop_local_environment
generate_certificates
generate_concourse_keys
start_local_environment
init_vault
unseal_vault
configure_vault
print_urls

copy_env_variables_to_local_folder