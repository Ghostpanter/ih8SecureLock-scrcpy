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
CFLAGS=(-shared -fPIC -O2 -std=c++17 -fno-exceptions -fno-rtti -fvisibility=hidden
        -fvisibility-inlines-hidden -DANDROID -I"$JNI" -llog -Wl,--exclude-libs,ALL -Wl,-z,max-page-size=16384)

build_one() {
  local triple="$1" so_name="$2"
  local cc="$TOOLCHAIN/${triple}${API}-clang++"
  echo "==> Building $so_name ($triple)"
  "$cc" "${CFLAGS[@]}" "${SRCS[@]}" -o "$OUT/$so_name"
  "$TOOLCHAIN/llvm-strip" -s "$OUT/$so_name"
  ls -la "$OUT/$so_name"
}

build_one aarch64-linux-android arm64-v8a.so
build_one armv7a-linux-androideabi armeabi-v7a.so
build_one i686-linux-android x86.so
build_one x86_64-linux-android x86_64.so
echo "Build OK"
