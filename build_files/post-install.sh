#!/usr/bin/bash

set -ouex pipefail

# Enable getty on tty1 for image with no Display Manager
#if [[ "$IMAGE_NAME" == "base" ]]; then
    systemctl enable getty@tty1
#fi

# Workaround: Rename just's CN readme to README.zh-cn.md
mv '/usr/share/doc/just/README.中文.md' '/usr/share/doc/just/README.zh-cn.md'

# Remove dnf5 versionlocks
dnf5 versionlock clear

# Enable Update Timers
systemctl enable rpm-ostreed-automatic.timer
systemctl enable flatpak-system-update.timer
systemctl --global enable flatpak-user-update.timer

# Configure staged updates for rpm-ostree
cp /usr/share/ublue-os/update-services/etc/rpm-ostreed.conf /etc/rpm-ostreed.conf

# Fix cjk fonts
ln -s "/usr/share/fonts/google-noto-sans-cjk-fonts" "/usr/share/fonts/noto-cjk"

# Add linuxbrew to the list of paths usable by `sudo`
# Even though brew isn't installed as part of this image, it's fine to add it here as it's reused by multiple ublue images
sed -Ei "s/secure_path = (.*)/secure_path = \1:\/home\/linuxbrew\/.linuxbrew\/bin/" /etc/sudoers

# Remove coprs
dnf5 -y copr remove ublue-os/staging
dnf5 -y copr remove ublue-os/packages
<<<<<<< HEAD
=======
#dnf5 -y copr remove kylegospo/oversteer
>>>>>>> 4f9a014 (patches to support trunk os)

# Disable Negativo17 Fedora Multimedia
# This needs to be a whole organiztion change
# dnf5 config-manager setopt fedora-multimedia.enabled=0

# Cleanup
# Remove tmp files and everything in dirs that make bootc unhappy
rm -rf /tmp/* || true
rm -rf /usr/etc
rm -rf /boot && mkdir /boot
# Preserve cache mounts
find /var/* -maxdepth 0 -type d \! -name cache \! -name log -exec rm -rf {} \;
find /var/cache/* -maxdepth 0 -type d \! -name libdnf5 -exec rm -rf {} \;

# Make sure /var/tmp is properly created
mkdir -p /var/tmp
chmod -R 1777 /var/tmp

# Check to make sure important packages are present
/ctx/check-build.sh

dnf5 clean all
rm -rf /var/cache/libdnf5
rm -f /var/log/dnf5.log

# bootc/ostree checks
bootc container lint
ostree container commit
