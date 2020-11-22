#!/usr/bin/env bash

set -euo pipefail

cmd=$1

curl cheat.sh/"$cmd"
