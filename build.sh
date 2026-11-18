#!/bin/bash
set -euo pipefail

project_dir="$(cd "$(dirname "$0")" && pwd)"
build_dir="$project_dir/build"
app_name='Mochi Snap.app'
stage="$(mktemp -d "${TMPDIR:-/tmp}/my-screenshot.XXXXXXXX")"
trap 'rm -rf "$stage"' EXIT

bundle="$stage/$app_name"
iconset="$stage/AppIcon.iconset"
mkdir -p "$bundle/Contents/MacOS" "$bundle/Contents/Resources" "$iconset" "$build_dir"
cp "$project_dir/Info.plist" "$bundle/Contents/Info.plist"
ditto "$project_dir/Resources" "$bundle/Contents/Resources"

for arch in arm64 x86_64; do
    xcrun swiftc -O -swift-version 6 -target "$arch-apple-macosx15.2" \
        "$project_dir/Sources/main.swift" "$project_dir/Sources/CaptureCanvas.swift" "$project_dir/Sources/MochiStyle.swift" -o "$stage/MochiSnap-$arch"
done
xcrun lipo -create "$stage/MochiSnap-arm64" "$stage/MochiSnap-x86_64" \
    -output "$bundle/Contents/MacOS/MochiSnap"
xcrun swift "$project_dir/Sources/icon.swift" "$iconset"
cp "$iconset/icon_512x512.png" "$bundle/Contents/Resources/Mascot.png"
iconutil -c icns "$iconset" -o "$bundle/Contents/Resources/AppIcon.icns"
signing_identity="${MYSCREENSHOT_SIGNING_IDENTITY:--}"
if [[ "$signing_identity" == "-" ]]; then
    codesign --force --sign - "$bundle"
else
    codesign --force --options runtime --timestamp --sign "$signing_identity" "$bundle"
fi
codesign --verify --strict "$bundle"
rm -rf "$build_dir/$app_name"
mv "$bundle" "$build_dir/$app_name"
printf '%s\n' "$build_dir/$app_name"
