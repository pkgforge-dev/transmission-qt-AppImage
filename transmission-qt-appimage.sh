#!/bin/sh

set -ex

ARCH="$(uname -m)"
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
UPINFO="gh-releases-zsync|$(echo $GITHUB_REPOSITORY | tr '/' '|')|latest|*$ARCH.AppImage.zsync"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"
PELF="https://github.com/xplshn/pelf/releases/latest/download/pelf_$ARCH"

# The arch package does not have icon lol
ICON="https://raw.githubusercontent.com/transmission/transmission/refs/heads/main/icons/hicolor_apps_scalable_transmission.svg"

VERSION="$(pacman -Q transmission-qt | awk '{print $2; exit}')"
echo "$VERSION" > ~/version

export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export OUTNAME=Transmission-Qt-"$VERSION"-anylinux-"$ARCH".AppImage

# Prepare AppDir
mkdir -p ./AppDir
cp -v /usr/share/applications/transmission-qt.desktop ./AppDir
wget --retry-connrefused --tries=30 "$ICON" -O ./AppDir/transmission.svg
cp -v ./AppDir/transmission.svg ./AppDir/.DirIcon

# ADD LIBRARIES
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun /usr/bin/transmission-qt /usr/lib/qt6/plugins/tls/*
ln ./AppDir/sharun ./AppDir/AppRun

# MAKE APPIMAGE WITH URUNTIME
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage

# make appbundle
wget --retry-connrefused --tries=30 "$PELF" -O ./pelf
chmod +x ./pelf
echo "Generating [dwfs]AppBundle..."
UPINFO="gh-releases-zsync|$(echo $GITHUB_REPOSITORY | tr '/' '|')|latest|*$ARCH.dwfs.AppBundle.zsync"
./pelf \
	--compression "-C zstd:level=22 -S26 -B8" \
	--appimage-compat                         \
	--add-updinfo "$UPINFO"                   \
	--appbundle-id="com.transmissionbt.Transmission#github.com/$GITHUB_REPOSITORY:$VERSION@$(date +%d_%m_%Y)" \
	--add-appdir ./AppDir                     \
	--output-to Transmission-Qt-"$VERSION"-anylinux-"$ARCH".dwfs.AppBundle

echo "Generating zsync file..."
zsyncmake *.AppBundle -u *.AppBundle

echo "All Done!"
