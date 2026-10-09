#!/usr/bin/env bash
# Builds Idiaitera.apk from docs/ with Capacitor. Run from the repo root.
set -euxo pipefail
echo "node $(node -v) | java: $(java -version 2>&1 | head -1)"
export ANDROID_HOME="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-/usr/local/lib/android/sdk}}"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
echo "ANDROID_HOME=$ANDROID_HOME"; ls "$ANDROID_HOME" || true
SDKM=$(ls "$ANDROID_HOME"/cmdline-tools/*/bin/sdkmanager 2>/dev/null | head -1 || true)
if [ -n "$SDKM" ]; then yes | "$SDKM" --licenses >/dev/null || true; fi

npm install --no-audit --no-fund
npx cap add android
npx cap sync android

for d in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
  res=android/app/src/main/res/mipmap-$d
  cp resources/icon-$d.png "$res/ic_launcher.png"
  cp resources/icon-$d.png "$res/ic_launcher_round.png"
  rm -f "$res/ic_launcher_foreground.png"
done
rm -rf android/app/src/main/res/mipmap-anydpi-v26

cd android
chmod +x gradlew
./gradlew assembleDebug --no-daemon --stacktrace
cd ..
cp android/app/build/outputs/apk/debug/app-debug.apk Idiaitera.apk
ls -la Idiaitera.apk
