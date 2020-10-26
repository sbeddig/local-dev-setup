#!/bin/bash

FLY_VERSION=6.6.0
wget https://github.com/concourse/concourse/releases/download/v$FLY_VERSION/fly-$FLY_VERSION-linux-amd64.tgz

tar -xvzf fly-$FLY_VERSION-linux-amd64.tgz
rm fly-$FLY_VERSION-linux-amd64.tgz

sudo mv fly /usr/local/bin/