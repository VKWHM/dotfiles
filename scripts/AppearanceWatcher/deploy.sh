#!/usr/bin/env bash
set -euo pipefail

### CONFIGURATION
# Name of your executable target
BIN_NAME="appearance-watcher"

# Where to install the binary
TARGET_BIN_DIR="${HOME}/.local/bin"

# LaunchAgent info
LABEL="com.$(whoami).appearancewatcher"
PLIST_DIR="${HOME}/Library/LaunchAgents"
PLIST_PATH="${PLIST_DIR}/${LABEL}.plist"

### 1) Build the project
echo "⏳ Building ${BIN_NAME}…"
swift build -c release

### 2) Install the binary
mkdir -p "$TARGET_BIN_DIR"
echo "📦 Installing binary to ${TARGET_BIN_DIR}/${BIN_NAME}"
cp ".build/release/${BIN_NAME}" "${TARGET_BIN_DIR}/${BIN_NAME}"
chmod +x "${TARGET_BIN_DIR}/${BIN_NAME}"

### 3) Create LaunchAgent plist if missing
if [ ! -f "$PLIST_PATH" ]; then
  echo "🆕 Generating LaunchAgent plist at $PLIST_PATH"
  mkdir -p "$PLIST_DIR"
  cat >"$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" \
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
    <string>${LABEL}</string>
  <key>ProgramArguments</key>
    <array>
      <string>${TARGET_BIN_DIR}/${BIN_NAME}</string>
    </array>
  <key>RunAtLoad</key>
    <true/>
  <key>KeepAlive</key>
    <true/>
  <key>StandardOutPath</key>
    <string>${HOME}/Library/Logs/${LABEL}.out.log</string>
  <key>StandardErrorPath</key>
    <string>${HOME}/Library/Logs/${LABEL}.err.log</string>
</dict>
</plist>
EOF
else
  echo "✅ LaunchAgent plist already exists at $PLIST_PATH"
fi

### 4) Load into launchd if not already loaded
if ! launchctl list | grep -q "^${LABEL}\b"; then
  echo "🚀 Loading ${LABEL} into launchd…"
  launchctl load "$PLIST_PATH"
else
  echo "ℹ️  ${LABEL} is already loaded. To reload, run:"
  echo "    launchctl unload \"$PLIST_PATH\" && launchctl load \"$PLIST_PATH\""
fi

echo "🎉 Done!"
