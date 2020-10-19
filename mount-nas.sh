#!/usr/bin/env bash

set -euo --pipefail

mkdir -p /home/simon/Beddig-NAS/ebooks
mkdir -p /home/simon/Beddig-NAS/homes
mkdir -p /home/simon/Beddig-NAS/music
mkdir -p /home/simon/Beddig-NAS/photo
mkdir -p /home/simon/Beddig-NAS/programs
mkdir -p /home/simon/Beddig-NAS/video

cat <<EOF | sudo tee -a /etc/fstab

192.168.2.29:/volume1/ebooks /home/simon/Beddig-NAS/ebooks nfs auto,user,defaults,tcp,intr 0 0
192.168.2.29:/volume1/homes /home/simon/Beddig-NAS/homes nfs auto,user,defaults,tcp,intr 0 0
192.168.2.29:/volume1/music /home/simon/Beddig-NAS/music nfs auto,user,defaults,tcp,intr 0 0
192.168.2.29:/volume1/photo /home/simon/Beddig-NAS/photo nfs auto,user,defaults,tcp,intr 0 0
192.168.2.29:/volume1/programs /home/simon/Beddig-NAS/programs nfs auto,user,defaults,tcp,intr 0 0
192.168.2.29:/volume1/video /home/simon/Beddig-NAS/video nfs auto,user,defaults,tcp,intr 0 0
EOF
