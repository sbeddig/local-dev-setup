#!/usr/bin/env bash

set -euo pipefail

VERSION=2021.1.2

wget https://download.jetbrains.com/idea/ideaIU-$VERSION.tar.gz

FOLDER=$(tar -tvf ideaIU-$VERSION.tar.gz)

tar -xzf ideaIU-$VERSION.tar.gz
rm ideaIU-$VERSION.tar.gz

sudo mv "$FOLDER" /opt/intellij-ultimate

