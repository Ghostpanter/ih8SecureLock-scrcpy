#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER=$(grep '^version=' "$ROOT/module/module.prop" | cut -d= -f2)
STAGE="$ROOT/out/stage"
DIST="$ROOT/out/dist"
rm -rf "$STAGE"
mkdir -p "$STAGE/zygisk" "$DIST"
cp "$ROOT/module/module.prop" "$STAGE/"
cp "$ROOT/module/customize.sh" "$STAGE/"
cp -r "$ROOT/module/META-INF" "$STAGE/"
cp "$ROOT/out/zygisk/"*.so "$STAGE/zygisk/"
# Magisk does not need README inside zip, but include NOTICE for license
cp "$ROOT/NOTICE" "$STAGE/" 2>/dev/null || true
cp "$ROOT/LICENSE" "$STAGE/" 2>/dev/null || true
ZIP="$DIST/ih8SecureLock-scrcpy-${VER}.zip"
rm -f "$ZIP"
( cd "$STAGE" && zip -9 -r "$ZIP" . )
sha256sum "$ZIP" | tee "$ZIP.sha256"
ls -la "$ZIP"
