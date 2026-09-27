#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NDK="${ANDROID_NDK_HOME:-/workspace/android-sdk/ndk/28.2.13676358}"
TOOLCHAIN="$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin"
API=21
JNI="$ROOT/zygisk/jni"
OUT="$ROOT/out/zygisk"
mkdir -p "$OUT"

SRCS=("$JNI/module.cpp" "$JNI/binder.cpp")
# -static-libstdc++ => link libc++ statically so Zygisk dlopen does not need libc++_shared.so
CFLAGS=(-shared -fPIC -O2 -std=c++17 -fno-exceptions -fno-rtti -fvisibility=hidden
        -fvisibility-inlines-hidden -DANDROID -I"$JNI" -llog
        -static-libstdc++
        -Wl,--exclude-libs,ALL -Wl,-z,max-page-size=16384)

build_one() {
  local triple="$1" so_name="$2"
  local cc="$TOOLCHAIN/${triple}${API}-clang++"
  echo "==> Building $so_name ($triple)"
  "$cc" "${CFLAGS[@]}" "${SRCS[@]}" -o "$OUT/$so_name"
  "$TOOLCHAIN/llvm-strip" -s "$OUT/$so_name"
  ls -la "$OUT/$so_name"
  if "$TOOLCHAIN/llvm-readelf" -d "$OUT/$so_name" | grep -q 'libc++_shared\.so'; then
    echo "ERROR: $so_name still NEEDs libc++_shared.so" >&2
    "$TOOLCHAIN/llvm-readelf" -d "$OUT/$so_name" | grep NEEDED >&2 || true
    exit 1
  fi
  echo "    NEEDED:" 
  "$TOOLCHAIN/llvm-readelf" -d "$OUT/$so_name" | grep NEEDED || true
}

build_one aarch64-linux-android arm64-v8a.so
build_one armv7a-linux-androideabi armeabi-v7a.so
build_one i686-linux-android x86.so
build_one x86_64-linux-android x86_64.so
echo "Build OK (c++_static / no libc++_shared.so)"
