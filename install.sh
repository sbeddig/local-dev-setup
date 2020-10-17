#!/usr/bin/env bash

set -euo --pipefail

export DEBIAN_FRONTEND=noninteractive

install_common_apps() {
  sudo apt install -y \
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
    lm-sensors
  sudo snap install bitwarden
}

configure_zsh() {
  sudo apt install -y zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  cat <<\EOF >>"$HOME"/.bashrc

  export SHELL=$(which zsh)
  [ -z "$ZSH_VERSION" ] && exec "$SHELL" -l
EOF

  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  curl -sfL git.io/antibody | sudo sh -s - -b /usr/local/bin

  mkdir -p ~/.zsh/completion
  curl -L https://raw.githubusercontent.com/docker/compose/1.27.4/contrib/completion/zsh/_docker-compose >~/.zsh/completion/_docker-compose

  cp zsh/.zshrc ~/.zshrc
  cp zsh/.zsh_plugins ~/.zsh_plugins
  cp zsh/.p10k.zsh ~/.p10k.zsh
}

install_dev_apps() {
  sudo snap install intellij-idea-ultimate --classic &&
    sudo ln -s /snap/intellij-idea-ultimate/current/bin/idea.sh /usr/local/bin/idea
  sudo snap install code --classic
  sudo snap install drawio
  sudo apt install -y \
    python3 \
    python3-pip \
    docker.io \
    docker-compose \
    awscli

  sudo groupadd docker
  sudo usermod -aG docker "$USER"
}

clone_repos() {
  mkdir -p "$HOME"/repositories
  cd "$HOME"/repositories
  repos=$(cat repositories)
  for repo in $repos; do
    git clone git@github.com:sbeddig/"$repo".git
  done
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
  dconf write /org/gnome/shell/favorite-apps "['firefox.desktop', 'org.gnome.Nautilus.desktop', \
    'intellij-idea-ultimate_intellij-idea-ultimate.desktop', 'org.gnome.Terminal.desktop']"
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
}

install_shell_extension() {
  extension=$1
  wget "https://extensions.gnome.org/extension-data/$extension"
  uuid=$(unzip -c "$extension" metadata.json | tail -n+3 | jq -r .uuid)
  mkdir -p ~/.local/share/gnome-shell/extensions/"$uuid"
  unzip -q "$extension" -d ~/.local/share/gnome-shell/extensions/"$uuid"/
  gnome-shell-extension-tool -e "$uuid"
  rm "$extension"
}

configure_security() {
  sudo ufw enable
}

set_wallpaper() {
  mkdir -p "$HOME"/Pictures/Wallpapers
  cp wallpaper.png "$HOME"/Pictures/Wallpapers/

  dconf write /org/gnome/desktop/background/picture-uri "'file:///home/simon/Pictures/Wallpapers/wallpaper.png'"
}

install_dev_libs() {
  curl -s "https://get.sdkman.io" | bash
  sdk install java 8.0.265-amzn

  curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
  sudo apt install -y nodejs gcc g++ make
  curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
  sudo apt update && sudo apt install yarn

  sudo add-apt-repository ppa:longsleep/golang-backports -y
  sudo apt update && sudo apt install golang-go -y
}

laptop_tools() {
  sudo apt install laptop-mode-tools
}

install_common_apps
configure_zsh

install_dev_libs
install_dev_apps
clone_repos

configure_desktop
configure_security
set_wallpaper

#laptop_tools
