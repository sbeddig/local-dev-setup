#!/usr/bin/env bash

set -euo pipefail

INSTALL_DIR=$PWD

install_zsh() {
  if ! command -v zsh; then
    sudo apt install -y zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

    #  cat <<\EOF >>"$HOME"/.bashrc
    #
    #  export SHELL=$(which zsh)
    #  [ -z "$ZSH_VERSION" ] && exec "$SHELL" -l
    #EOF
    zsh_path=$(command -v zsh)
    chsh -s "$zsh_path"

    curl -sfL git.io/antibody | sudo sh -s - -b /usr/local/bin

    mkdir -p ~/.zsh/completion
    curl -L https://raw.githubusercontent.com/docker/compose/1.27.4/contrib/completion/zsh/_docker-compose >~/.zsh/completion/_docker-compose

    cp "$INSTALL_DIR"/zsh/.bash_aliases ~/.bash_aliases
    cp "$INSTALL_DIR"/zsh/.zshrc ~/.zshrc
    cp "$INSTALL_DIR"/zsh/.zsh_plugins.txt ~/.zsh_plugins.txt
    cp "$INSTALL_DIR"/zsh/.p10k.zsh ~/.p10k.zsh
  fi
}

install_zsh