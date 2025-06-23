#!/bin/sh

sed -i '' -e 's/quarterly/latest/' /etc/pkg/FreeBSD.conf

export ASSUME_ALWAYS_YES=true

pkg install autoconf bash boost-libs catch2 cmake ccache enet ffmpeg fusefs-libs \
            gcc gmake git glslang llvm libfmt libzip liblz4 lzlib mbedtls3 nasm \
            ninja nlohmann-json openssl opus pkgconf qt6-base qt6ct qt6-multimedia \
            qt6-tools qt6-translations qt6-wayland sdl2 sdl3 unzip vulkan-headers wget zip zstd
