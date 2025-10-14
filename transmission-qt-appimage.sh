#!/bin/sh

set -eux

ARCH="$(uname -m)"
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"
VERSION="$(cat ~/version)"

export ADD_HOOKS="self-updater.bg.hook"
# The arch package does not have icon lol
export ICON="https://raw.githubusercontent.com/transmission/transmission/refs/heads/main/icons/hicolor_apps_scalable_transmission.svg"
export DESKTOP="/usr/share/applications/transmission-qt.desktop"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export OUTNAME=Transmission-Qt-"$VERSION"-anylinux-"$ARCH".AppImage

# Deploy dependencies
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun /usr/bin/transmission-qt

# MAKE APPIMAGE WITH URUNTIME
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage

# make appbundle
wget --retry-connrefused --tries=30 \
	"https://github.com/xplshn/pelf/releases/latest/download/pelf_$ARCH" -O ./pelf
chmod +x ./pelf
echo "Generating [dwfs]AppBundle..."
UPINFO="$(echo "$UPINFO" | sed 's#.AppImage.zsync#*.AppBundle.zsync#g')"
./pelf \
	--compression "-C zstd:level=22 -S26 -B8" \
	--appimage-compat                         \
	--add-updinfo "$UPINFO"                   \
	--appbundle-id="com.transmissionbt.Transmission#github.com/$GITHUB_REPOSITORY:$VERSION@$(date +%d_%m_%Y)" \
	--add-appdir ./AppDir                     \
	--output-to Transmission-Qt-"$VERSION"-anylinux-"$ARCH".dwfs.AppBundle

echo "Generating zsync file..."
zsyncmake *.AppBundle -u *.AppBundle

mkdir -p ./dist
mv -v ./*.AppImage*  ./dist
mv -v ./*.AppBundle* ./dist
mv -v ~/version      ./dist

echo "All Done!"
