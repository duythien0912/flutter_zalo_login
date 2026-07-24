#!/usr/bin/env bash
# Android E2E for the flutter_zalo_login example app via Maestro.
# Builds + installs a debug APK on a running emulator/device, runs every flow
# in .maestro/, and collects the in-flow screenshots.
# Verify with BOTH the Maestro assertions and the PNGs.
#
#   ./tool/e2e/run_android_e2e.sh [outDir]
#
# Prereqs: a booted Android emulator/device (`adb devices`), maestro, flutter.
#
# Note: flows that complete a real Zalo login need either the Zalo app / a
# logged-in browser session on the device, or a human to scan the QR while the
# flow waits. Login-independent flows (init, hash key) always pass headless.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
EXAMPLE_DIR="$REPO_DIR/example"
FLOWS_DIR="$REPO_DIR/.maestro"
OUT="${1:-$REPO_DIR/build/e2e-android}"
APK="$EXAMPLE_DIR/build/app/outputs/flutter-apk/app-debug.apk"

# Derive applicationId from Gradle (single source of truth) — never hardcode.
APP_ID="$(grep -Eom1 'applicationId[[:space:]]*=?[[:space:]]*"[^"]+"' "$EXAMPLE_DIR/android/app/build.gradle" | sed -E 's/.*"([^"]+)".*/\1/')"
if [ -z "${APP_ID:-}" ]; then echo "could not read applicationId from build.gradle" >&2; exit 1; fi

export PATH="$PATH:$HOME/.maestro/bin"
mkdir -p "$OUT"

echo "› waiting for a device…"
adb wait-for-device
adb devices

echo "› building debug APK…"
( cd "$EXAMPLE_DIR" && flutter build apk --debug )

echo "› installing ${APP_ID} …"
adb install -r -g "$APK"

echo "› running Maestro flows (APP_ID=$APP_ID)…"
# Screenshots from `takeScreenshot` land in the working dir → run from $OUT.
# Flows reference the id as ${APP_ID}; inject it here so nothing is hardcoded.
#
# Run flows ONE AT A TIME in filename order: they share a single emulator and a
# single app instance and several use `clearState`, so running them concurrently
# would let one flow's state wipe another's mid-run.
cd "$OUT"
PASS=0; FAIL=0; FAILED=""
for flow in $(ls "$FLOWS_DIR"/*.yaml | sort); do
  name="$(basename "$flow")"
  echo "  › $name"
  if maestro test -e APP_ID="$APP_ID" "$flow" > "$OUT/${name%.yaml}.log" 2>&1; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1)); FAILED="$FAILED $name"
  fi
done

echo "› done. $PASS passed, $FAIL failed.${FAILED:+ FAILED:$FAILED}"
echo "› per-flow logs + screenshots (*.png) in $OUT"
ls -1 "$OUT"/*.png 2>/dev/null || true
[ "$FAIL" -eq 0 ]
