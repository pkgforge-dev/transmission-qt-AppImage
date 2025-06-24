#!/bin/sh

set -ex

export ARCH="$(uname -m)"
URUNTIME="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-$ARCH"
URUNTIME_LITE="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-lite-$ARCH"
UPINFO="gh-releases-zsync|$(echo $GITHUB_REPOSITORY | tr '/' '|')|latest|*$ARCH.AppImage.zsync"
SHARUN="https://github.com/VHSgunzo/sharun/releases/latest/download/sharun-$ARCH-aio"
PELF="https://github.com/xplshn/pelf/releases/latest/download/pelf_$ARCH"

# The arch package does not have icon lol
ICON="https://raw.githubusercontent.com/transmission/transmission/refs/heads/main/icons/hicolor_apps_scalable_transmission.svg"

VERSION="$(pacman -Q transmission-qt | awk '{print $2; exit}')"
echo "$VERSION" > ~/version

# Prepare AppDir
mkdir -p ./AppDir && (
	cd ./AppDir
	cp -rv /usr/share/applications/transmission-qt.desktop ./
	wget --retry-connrefused --tries=30 "$ICON" -O ./transmission.svg
	cp -v ./transmission.svg ./.DirIcon

	# ADD LIBRARIES
	wget --retry-connrefused --tries=30 "$SHARUN" -O ./sharun-aio
	chmod +x ./sharun-aio
	xvfb-run -a \
		./sharun-aio l -p -v -e -s -k                \
		/usr/bin/transmission-qt                     \
		/usr/lib/qt6/plugins/imageformats/*          \
		/usr/lib/qt6/plugins/iconengines/*           \
		/usr/lib/qt6/plugins/platforms/*             \
		/usr/lib/qt6/plugins/platformthemes/*        \
		/usr/lib/qt6/plugins/platforminputcontexts/* \
		/usr/lib/qt6/plugins/styles/*                \
		/usr/lib/qt6/plugins/tls/*                   \
		/usr/lib/qt6/plugins/xcbglintegrations/*     \
		/usr/lib/qt6/plugins/wayland-*/*
	rm -f ./sharun-aio
	ln ./sharun ./AppRun
	./sharun -g
)

# MAKE APPIAMGE WITH URUNTIME
wget --retry-connrefused --tries=30 "$URUNTIME"      -O ./uruntime
wget --retry-connrefused --tries=30 "$URUNTIME_LITE" -O ./uruntime-lite
chmod +x ./uruntime*

# Add udpate info to runtime
echo "Adding update information \"$UPINFO\" to runtime..."
./uruntime-lite --appimage-addupdinfo "$UPINFO"

echo "Generating AppImage..."
./uruntime --appimage-mkdwarfs -f \
	--set-owner 0 --set-group 0          \
	--no-history --no-create-timestamp   \
	--compression zstd:level=22 -S26 -B8 \
	--header uruntime-lite               \
	-i ./AppDir -o ./Transmission-Qt-"$VERSION"-anylinux-"$ARCH".AppImage

wget -O ./pelf "https://github.com/xplshn/pelf/releases/latest/download/pelf_$ARCH" 
chmod +x ./pelf

echo "Generating [dwfs]AppBundle..."
UPINFO="gh-releases-zsync|$(echo $GITHUB_REPOSITORY | tr '/' '|')|latest|*$ARCH.dwfs.AppBundle.zsync"
./pelf --add-appdir ./AppDir \
	--appimage-compat                         \
	--add-updinfo "$UPINFO"                   \
	--appbundle-id="Transmission-Qt-$VERSION" \
	--compression "-C zstd:level=22 -S26 -B8" \
	--output-to Transmission-Qt-"$VERSION"-anylinux-"$ARCH".dwfs.AppBundle

echo "Generating zsync file..."
zsyncmake *.AppImage -u *.AppImage
zsyncmake *.AppBundle -u *.AppBundle

echo "All Done!"
