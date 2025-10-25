#!/bin/sh

set -eux

EXTRA_PACKAGES="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/get-debloated-pkgs.sh"

echo "Installing dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	alsa-lib         \
	base-devel       \
	cmake            \
	curl             \
	git              \
	libglvnd         \
	libpulse         \
	libx11           \
	libxrandr        \
	libxss           \
	pipewire-audio   \
	pulseaudio       \
	pulseaudio-alsa  \
	qt6ct            \
	qt6-wayland      \
	transmission-qt  \
	wget             \
	xorg-server-xvfb \
	zsync

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$EXTRA_PACKAGES" -O ./get-debloated-pkgs.sh
chmod +x ./get-debloated-pkgs.sh
./get-debloated-pkgs.sh --add-common --prefer-nano

pacman -Q transmission-qt | awk '{print $2; exit}' > ~/version
