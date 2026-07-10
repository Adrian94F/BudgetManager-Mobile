#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
INPUT_FILE="$ROOT_DIR/build/ios/Release-iphoneos/Runner.app"
PAYLOAD_DIR="$ROOT_DIR/Payload"
ZIP_FILE="$ROOT_DIR/Payload.zip"
OUTPUT_IPA="$ROOT_DIR/BM.ipa"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Error: flutter command not found in PATH." >&2
  exit 1
fi

echo "Building iOS release (no codesign)..."
(
  cd "$ROOT_DIR"
  flutter build ios --release --no-codesign
)

if [ ! -d "$INPUT_FILE" ]; then
  echo "Error: input bundle not found: $INPUT_FILE" >&2
  exit 1
fi

if [ -e "$PAYLOAD_DIR" ] || [ -e "$ZIP_FILE" ]; then
  echo "Error: temporary artifacts already exist (Payload/ or Payload.zip). Remove them and retry." >&2
  exit 1
fi

rm -f "$OUTPUT_IPA"
mkdir -p "$PAYLOAD_DIR"

cleanup() {
  rm -rf "$PAYLOAD_DIR" "$ZIP_FILE"
}
trap cleanup EXIT INT TERM

mv "$INPUT_FILE" "$PAYLOAD_DIR/Runner.app"
(
  cd "$ROOT_DIR"
  zip -rq "$(basename "$ZIP_FILE")" "$(basename "$PAYLOAD_DIR")"
)

mv "$ZIP_FILE" "$OUTPUT_IPA"

echo "Created: $OUTPUT_IPA"
