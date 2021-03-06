#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

INSTALL_DIR=$PWD
TOOLS_DIR=$INSTALL_DIR/tools

install_common() {
  sudo apt update
  sudo apt upgrade -y
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
    libreoffice \
    hyphen-de \
    lm-sensors \
    python3 \
    postgresql-client \
    protobuf-compiler \
    python3-pip \
    docker.io \
    docker-compose
  sudo snap install bitwarden
  sudo snap install youtube-music-desktop-app
  sudo groupadd docker || true
  sudo usermod -aG docker "$USER" || true
  install_google_chrome
  install_no_sql_workbench
  install_intellij
}

install_google_chrome() {
  if ! google-chrome --version; then
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    rm google-chrome-stable_current_amd64.deb
  fi
}

install_no_sql_workbench() {
  if ! command -v nosql-workbench; then
    wget -O nosql-workbench.AppImage https://s3.amazonaws.com/nosql-workbench/NoSQL%20Workbench-linux-x86_64-2.0.0.AppImage
    chmod +x nosql-workbench.AppImage
    sudo mv nosql-workbench.AppImage /usr/local/bin/nosql-workbench
    sudo cp "$TOOLS_DIR"/nosql-workbench/nosql-workbench.png /usr/local/bin/
    sudo cp "$TOOLS_DIR"/nosql-workbench/nosql-workbench.desktop /usr/share/applications/
  fi
}

install_intellij() {
  if ! command -v idea; then
    cd tools/intellij
    ./install.sh
    cd "$INSTALL_DIR"
  fi
}

install_zsh() {
  cd "$TOOLS_DIR"
  ./configure_zsh.sh
  cd "$INSTALL_DIR"
}

install_vscode() {
  cd "$TOOLS_DIR"
  ./visual_studio_code.sh
  cd "$INSTALL_DIR"
}

install_dev() {
  install_sdkman
  install_node
  install_go
  sudo snap install task --classic
  sudo snap install drawio
  sudo snap install postman
  #  sudo pip3 install awscli
  install_aws_v2_cli
  sudo pip3 install awscli-local
  install_brew
  install_aws_sam_cli
}

install_aws_v2_cli() {
  mkdir "$INSTALL_DIR"/aws_tmp
  cd "$INSTALL_DIR"/aws_tmp
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  rm -rf "$INSTALL_DIR"/aws_tmp
}

install_brew() {
  if ! brew --version; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    # shellcheck disable=SC2016
    echo 'eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >>/home/simon/.zprofile
    echo 'source /home/simon/.zprofile' >>/home/simon/.zshrc
    # shellcheck disable=SC2046
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    brew install gcc
  fi
}

install_aws_sam_cli() {
  if ! sam --version; then
    brew tap aws/tap
    brew install aws-sam-cli
  fi
}

install_cfn_nag() {
  if ! cfn_nag --version; then
    brew install ruby brew-gem
    brew gem install cfn-nag
  fi
}

install_sdkman() {
  if [ ! -d "$HOME/.sdkman" ]; then
    curl -s "https://get.sdkman.io" | bash
    source "$HOME"/.sdkman/bin/sdkman-init.sh || true
    sdk install java 8.0.265-amzn
  fi
}

install_node() {
  sudo snap install node --classic
  sudo npm install -g npm@latest
}

install_go() {
  if ! go version; then
    sudo add-apt-repository ppa:longsleep/golang-backports -y
    sudo apt update && sudo apt install golang-go -
  fi
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
  dconf write /org/gnome/shell/favorite-apps "['firefox.desktop', 'google-chrome.desktop', 'thunderbird.desktop', 'org.gnome.Nautilus.desktop', 'intellij.desktop', 'code_code.desktop', 'postman_postman.desktop', 'nosql-workbench.desktop', 'org.gnome.Terminal.desktop']"
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
  cp "$TOOLS_DIR"/wallpaper.png "$HOME"/Pictures/Wallpapers/

  dconf write /org/gnome/desktop/background/picture-uri "'file:///home/simon/Pictures/Wallpapers/wallpaper.png'"
}

install_npm_libs() {
  sudo npm install -g typescript ts-node @angular/cli aws-cdk aws-cdk-local @vue/cli vue@next
  sudo npm update -g typescript ts-node @angular/cli aws-cdk aws-cdk-local @vue/cli vue@next
  sudo npm install -g npm
}

install_custom_scripts() {
  cp -r custom_scripts "$HOME"/.custom_scripts
}

cleanup() {
  sudo apt autoremove -y
}

install_quicktile() {
  if ! which quicktile; then
    sudo apt-get install python3 python3-pip python3-setuptools python3-gi python3-xlib python3-dbus gir1.2-glib-2.0 gir1.2-gtk-3.0 gir1.2-wnck-3.0 -y
    sudo pip3 install https://github.com/ssokolow/quicktile/archive/master.zip
    quicktile
    sed -i 's/KP_//' "$HOME"/.config/quicktile.cfg
  fi
  if [ ! -d "$HOME/.config/autostart/quicktile.desktop" ]; then
    cp "$TOOLS_DIR"/quicktile.desktop "$HOME"/.config/autostart/quicktile.desktop
  fi
  cp "$TOOLS_DIR"/quicktile.cfg "$HOME"/.config/quicktile.cfg
}

install_common &>/dev/null
install_zsh &>/dev/null
install_dev &>/dev/null
install_npm_libs &>/dev/null
install_custom_scripts &>/dev/null
install_quicktile &>/dev/null

configure_desktop &>/dev/null
set_wallpaper &>/dev/null
configure_security &>/dev/null
install_vscode &>/dev/null

cleanup &>/dev/null
