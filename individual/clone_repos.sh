#!/usr/bin/env bash

set -euo pipefail

INSTALL_DIR=$PWD

clone_repos() {
  mkdir -p "$HOME"/repositories
  cd "$HOME"/repositories
  repositories=$(cat "$INSTALL_DIR"/repos)
  for repo in $repositories; do
    git clone git@github.com:sbeddig/"$repo".git || true
  done
  cd "$INSTALL_DIR"
}

clone_repos