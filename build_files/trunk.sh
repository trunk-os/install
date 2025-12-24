#!/bin/sh

set -xeuo pipefail

curl -sSL sh.rustup.rs >boot-rustup && chmod +x boot-rustup && ./boot-rustup -y && rm boot-rustup
source $HOME/.cargo/env && cargo install --git https://github.com/trunk-os/control-plane charon && mv /root/.cargo/bin/charon /usr/bin

systemctl enable buckle.service charon.service gild.service hostname.service panel.service avahi-daemon.service
systemctl disable avahi-daemon.socket
systemctl disable firewalld
