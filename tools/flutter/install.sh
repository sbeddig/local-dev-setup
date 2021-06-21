#!/usr/bin/env bash

set -euo pipefail

sudo snap install flutter --classic
flutter sdk-path

flutter upgrade

wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/4.2.1.0/android-studio-ide-202.7351085-linux.tar.gz

tar -xzf android-studio-ide-202.7351085-linux.tar.gz
rm android-studio-ide-202.7351085-linux.tar.gz

sudo mv android-studio /opt/android-studio

/opt/android-studio/bin/studio.sh
