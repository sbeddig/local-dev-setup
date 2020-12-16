#!/usr/bin/env bash

set -euo pipefail

laptop_tools() {
  sudo apt install laptop-mode-tools tlp tlp-rdw
}

laptop_tools