#!/bin/bash

set -exu # -u: exit if referenced variables aren't assigned
         # -e: exit upon command error (NOTE: Builtin operator failures are handled differently depending the shell. POSIX behavior would be to quit, even if the condition was done with `test` )
         # -x: Print values of referenced variables, assignments, conditions and commands as they are executed/evaluated

export APPIMAGE_EXTRACT_AND_RUN=1
# shellcheck disable=SC2155 # Its unlikely that uname -m will fail
export ARCH="$(uname -m)"

URUNTIME="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-$ARCH"
PELF="https://github.com/xplshn/pelf/releases/latest/download/pelf_$ARCH"

case "$1" in
    steamdeck)
        echo "Making Eden Optimized Build for Steam Deck"
        CMAKE_CXX_FLAGS="-march=znver2 -mtune=znver2 -O3 -pipe -flto=auto -Wno-error"
        CMAKE_C_FLAGS="-march=znver2 -mtune=znver2 -O3 -pipe -flto=auto -Wno-error"
	YUZU_USE_PRECOMPILED_HEADERS=OFF
	CCACHE="ccache"
        TARGET="Steamdeck"
        ;;
    common)
        echo "Making Eden Optimized Build for Modern CPUs"
        CMAKE_CXX_FLAGS="-march=x86-64-v3 -O3 -pipe -flto=auto -Wno-error"
        CMAKE_C_FLAGS="-march=x86-64-v3 -O3 -pipe -flto=auto -Wno-error"
	YUZU_USE_PRECOMPILED_HEADERS=OFF
	CCACHE="ccache"
        ARCH="${ARCH}_v3"
        TARGET="Common"
        ;;
    legacy)
        echo "Making Eden Optimized Build for Legacy CPUs"
        CMAKE_CXX_FLAGS="-march=x86-64 -mtune=generic -O2 -pipe -flto=auto -Wno-error"
        CMAKE_C_FLAGS="-march=x86-64 -mtune=generic -O2 -pipe -flto=auto -Wno-error"
	YUZU_USE_PRECOMPILED_HEADERS=OFF
	CCACHE="ccache"
        TARGET="Legacy"
        ;;
    aarch64)
        echo "Making Eden Optimized Build for AArch64"
        CMAKE_CXX_FLAGS="-march=armv8-a -mtune=generic -O3 -pipe -flto=auto -w"
        CMAKE_C_FLAGS="-march=armv8-a -mtune=generic -O3 -pipe -flto=auto -w"
        TARGET="Linux"
        ;;
esac

AI_UPINFO="gh-releases-zsync|$(echo "$GITHUB_REPOSITORY" | tr '/' '|')|latest|*$ARCH.AppImage.zsync"
AB_UPINFO="gh-releases-zsync|$(echo "$GITHUB_REPOSITORY" | tr '/' '|')|latest|*$ARCH.dwfs.AppBundle.zsync"

# Clone Eden, fallback to mirror if upstream repo fails to clone
if ! git clone 'https://git.eden-emu.dev/eden-emu/eden.git' ./eden; then
	echo "Using mirror instead..."
	rm -rf ./eden || true
	git clone 'https://github.com/pflyly/eden-mirror.git' ./eden
fi

cd ./eden
git submodule update --init --recursive
COUNT="$(git rev-list --count HEAD)"
DATE="$(date +"%d_%m_%Y")"

# workaround for aarch64
if [ "$1" = 'aarch64' ]; then
    sed -i 's/Settings::values\.lru_cache_enabled\.GetValue()/true/' src/core/arm/nce/patcher.h
fi

mkdir build
cd build
cmake .. -GNinja \
    -DYUZU_USE_BUNDLED_VCPKG=OFF \
    -DYUZU_USE_BUNDLED_QT=OFF \
    -DYUZU_TESTS=OFF \
    -DYUZU_CHECK_SUBMODULES=OFF \
    -DYUZU_USE_FASTER_LD=ON \
    -DYUZU_ENABLE_LTO=ON \
    -DENABLE_QT_TRANSLATION=ON \
    -DUSE_DISCORD_PRESENCE=OFF \
    -DYUZU_CMD=OFF \
    -DYUZU_ROOM_STANDALONE=OFF \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_SYSTEM_PROCESSOR="$(uname -m)" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_EXE_LINKER_FLAGS="-Wl,--as-needed" \
    -DCMAKE_C_COMPILER_LAUNCHER="${CCACHE:-}" \
    -DCMAKE_CXX_COMPILER_LAUNCHER="${CCACHE:-}" \
    ${YUZU_USE_PRECOMPILED_HEADERS:+-DYUZU_USE_PRECOMPILED_HEADERS=$YUZU_USE_PRECOMPILED_HEADERS} \
    ${CMAKE_CXX_FLAGS:+-DCMAKE_CXX_FLAGS="$CMAKE_CXX_FLAGS"} \
    ${CMAKE_C_FLAGS:+-DCMAKE_C_FLAGS="$CMAKE_C_FLAGS"}
ninja

if [ "$1" != 'aarch64' ]; then
    ccache -s -v
fi

cd ../..
# Use sharun to generate AppDir with mesa drivers
chmod +x ./sharun.sh
./sharun.sh ./eden/build

# Use linuxdeploy to generate AppDir without mesa drivers
chmod +x ./linuxdeploy.sh
./linuxdeploy.sh ./eden/build

# Prepare uruntime and pelf
wget -q "$URUNTIME" -O ./uruntime
chmod +x ./uruntime
wget -q "$PELF" -O ./pelf
chmod +x ./pelf

# Add update info to runtime
echo "Adding update information \"$AI_UPINFO\" to runtime..."
./uruntime --appimage-addupdinfo "$AI_UPINFO"

# Turn AppDir into appimage and appbundle, upload seperately
echo "Generating AppImage with mesa"
MESA_APPIMAGE="Eden-${COUNT}-${TARGET}-${ARCH}.AppImage"
./uruntime --appimage-mkdwarfs -f --set-owner 0 --set-group 0 --no-history --no-create-timestamp --compression zstd:level=22 -S26 -B8 \
--header uruntime -i ./eden/build/mesa/AppDir -o "$MESA_APPIMAGE"

echo "Generating zsync file for $MESA_APPIMAGE"
zsyncmake -v "$MESA_APPIMAGE" -u "$MESA_APPIMAGE"

mkdir -p mesa
mv -v "${MESA_APPIMAGE}"* mesa/

echo "Generating AppBundle...(Go runtime)"
APPBUNDLE="Eden-${COUNT}-${TARGET}-${ARCH}.dwfs.AppBundle"
ln -sfv ./eden/build/mesa/AppDir/eden.svg ./eden/build/mesa/AppDir/.DirIcon.svg
./pelf --add-appdir ./eden/build/mesa/AppDir --appbundle-id="Eden-${DATE}-Escary" --compression "-C zstd:level=22 -S26 -B8" --output-to "$APPBUNDLE" --add-updinfo "$AB_UPINFO"

echo "Generating zsync file for $APPBUNDLE"
zsyncmake -v "$APPBUNDLE" -u "$APPBUNDLE"

mkdir -p bundle
mv -v "${APPBUNDLE}"* bundle/

echo "Generating AppImage without mesa"
LIGHT_APPIMAGE="Eden-${COUNT}-${TARGET}-light-${ARCH}.AppImage"
./uruntime --appimage-mkdwarfs -f --set-owner 0 --set-group 0 --no-history --no-create-timestamp --compression zstd:level=22 -S26 -B8 \
--header uruntime -i ./eden/build/light/AppDir -o "$LIGHT_APPIMAGE"

echo "Generating zsync file for $LIGHT_APPIMAGE"
zsyncmake -v "$LIGHT_APPIMAGE" -u "$LIGHT_APPIMAGE"

mkdir -p light
mv -v "${LIGHT_APPIMAGE}"* light/

echo "All Done!"
