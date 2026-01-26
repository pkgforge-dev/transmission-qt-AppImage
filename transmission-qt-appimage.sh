#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q transmission-qt | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=https://raw.githubusercontent.com/transmission/transmission/refs/heads/main/icons/hicolor_apps_scalable_transmission.svg
export DESKTOP=/usr/share/applications/transmission-qt.desktop

# Deploy dependencies
quick-sharun /usr/bin/transmission /usr/share/transmission

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage
