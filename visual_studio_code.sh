#!/usr/bin/env bash

set -euo pipefail

install_plugins() {
  code --install-extension amazonwebservices.aws-toolkit-vscode
  code --install-extension ms-azuretools.vscode-docker
  code --install-extension esbenp.prettier-vscode
  code --install-extension octref.vetur #vue.js https://marketplace.visualstudio.com/items?itemName=octref.vetur

  # angular
  code --install-extension johnpapa.angular2
  code --install-extension angular.ng-template
  code --install-extension alexiv.vscode-angular2-files
  code --install-extension cyrilletuzi.angular-schematics
}

setup_vscode() {
  settings=$(cat "$HOME"/.config/Code/User/settings.json)

  settings=$(echo "$settings" | jq '. += {"editor.formatOnSave":true}')
  settings=$(echo "$settings" | jq '. += {"telemetry.enableTelemetry": false}')
  settings=$(echo "$settings" | jq '. += {"aws.telemetry": false}')
  settings=$(echo "$settings" | jq '. += {"telemetry.enableCrashReporter": false}')

  echo "$settings" >"$HOME"/.config/Code/User/settings.json
}

sudo snap install code --classic
install_plugins
setup_vscode
