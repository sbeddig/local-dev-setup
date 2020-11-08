#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

INSTALL_DIR=$PWD

install_common_apps() {
  sudo apt install -y \
    nfs-common \
    curl \
    jq \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    usb-creator-gtk \
    ubuntu-restricted-extras \
    git \
    htop \
    ctop \
    thunderbird \
    rhythmbox \
    vim \
    vlc \
    chromium-browser \
    libreoffice \
    hyphen-de \
    lm-sensors
  sudo snap install bitwarden
}

configure_zsh() {
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

install_dev_apps() {
  sudo snap install intellij-idea-ultimate --classic
  sudo ln -s /snap/intellij-idea-ultimate/current/bin/idea.sh /usr/local/bin/idea || true
  sudo snap install code --classic
  sudo snap install task --classic
  sudo snap install drawio
  sudo snap install postman
  sudo apt install -y \
    python3 \
    python3-pip \
    docker.io \
    docker-compose

  sudo pip3 install awscli
  sudo pip3 install awscli-local
  sudo groupadd docker || true
  sudo usermod -aG docker "$USER" || true
}

clone_repos() {
  mkdir -p "$HOME"/repositories
  cd "$HOME"/repositories
  repositories=$(cat "$INSTALL_DIR"/repos)
  for repo in $repositories; do
    git clone git@github.com:sbeddig/"$repo".git || true
  done
  cd "$INSTALL_DIR"
}

# dconf watch /
# https://askubuntu.com/questions/594919/how-to-configure-desktop-appearance-from-the-terminal
configure_desktop() {
  sudo apt update && sudo apt install -y \
    gnome-tweaks \
    gnome-shell-extensions
  dconf write /org/gnome/desktop/interface/gtk-theme "'Yaru-dark'"
  dconf write /org/gnome/shell/extensions/dash-to-dock/dock-position "'BOTTOM'"
  dconf write /org/gnome/shell/extensions/dash-to-dock/dock-fixed false
  dconf write /org/gnome/shell/favorite-apps "['firefox.desktop', 'thunderbird.desktop', 'org.gnome.Nautilus.desktop', 'intellij-idea-ultimate_intellij-idea-ultimate.desktop', 'code_code.desktop', 'postman_postman.desktop', 'org.gnome.Terminal.desktop']"
  dconf write /org/gnome/desktop/interface/clock-show-weekday true

  sudo apt install gnome-shell-extension-system-monitor
  dconf write /org/gnome/shell/extensions/system-monitor/cpu-display true
  dconf write /org/gnome/shell/extensions/system-monitor/cpu-style "'digit'"
  dconf write /org/gnome/shell/extensions/system-monitor/memory-display true
  dconf write /org/gnome/shell/extensions/system-monitor/memory-style "'digit'"
  dconf write /org/gnome/shell/extensions/system-monitor/thermal-display true
  dconf write /org/gnome/shell/extensions/system-monitor/thermal-style "'digit'"
  dconf write /org/gnome/shell/extensions/system-monitor/net-display false

  gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
  gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 64

  install_shell_extension unitehardpixel.eu.v43.shell-extension.zip
  dconf write /org/gnome/shell/extensions/unite/window-buttons-placement "'left'"
}

install_shell_extension() {
  extension=$1
  wget "https://extensions.gnome.org/extension-data/$extension"
  uuid=$(unzip -c "$extension" metadata.json | tail -n+3 | jq -r .uuid)
  gnome-extensions install "$extension" --force
  gnome-extensions enable "$uuid"
  rm "$extension"
}

configure_security() {
  sudo ufw enable
}

set_wallpaper() {
  mkdir -p "$HOME"/Pictures/Wallpapers
  cp "$INSTALL_DIR"/wallpaper.png "$HOME"/Pictures/Wallpapers/

  dconf write /org/gnome/desktop/background/picture-uri "'file:///home/simon/Pictures/Wallpapers/wallpaper.png'"
}

install_dev_libs() {
  #  if ! command -v sdk; then
  #    curl -s "https://get.sdkman.io" | bash
  #    # shellcheck disable=SC1090
  #    source ~/.sdkman/bin/sdkman-init.sh || true
  #    sdk install java 8.0.265-amzn
  #  fi'

  if ! node --version; then
    curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
    sudo apt install -y nodejs gcc g++ make
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt update && sudo apt install yarn
  fi

  if ! go version; then
    sudo add-apt-repository ppa:longsleep/golang-backports -y
    sudo apt update && sudo apt install golang-go -
  fi
}

install_npm_libs() {
  sudo npm install -g typescript @angular/cli aws-cdk
}

update_npm_libs() {
  sudo npm update -g typescript @angular/cli aws-cdk
}

install_vscode_plugins() {
  code --install-extension amazonwebservices.aws-toolkit-vscode
  code --install-extension ms-azuretools.vscode-docker
}

laptop_tools() {
  sudo apt install laptop-mode-tools tlp tlp-rdw
}

install_common_apps
configure_zsh

install_dev_libs
install_dev_apps

install_npm_libs
update_npm_libs
install_vscode_plugins

clone_repos

configure_desktop
configure_security
set_wallpaper

#laptop_tools
sudo apt autoremove -y
