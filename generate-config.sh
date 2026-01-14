#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_FILE="$SCRIPT_DIR/core-extra-packages.txt"
OUTPUT_FILE="$SCRIPT_DIR/archinstall_user_configuration.json"

echo "=== Generating archinstall JSON Configuration ==="
echo "Reading packages from $PACKAGES_FILE..."

# Read packages and format as JSON array using pure bash
PACKAGES="["
FIRST=true
while IFS= read -r line || [ -n "$line" ]; do
    # Skip comments and empty lines
    [[ "$line" =~ ^#.*$ ]] && continue
    [[ -z "$line" ]] && continue
    
    # Add comma before all items except the first
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        PACKAGES+=","
    fi
    
    # Escape quotes and add to array
    PACKAGES+="\"${line}\""
done < "$PACKAGES_FILE"
PACKAGES+="]"

echo "Generating $OUTPUT_FILE..."

cat >"$OUTPUT_FILE" <<EOF
{
  "archinstall-language": "English",
  "audio_config": {
    "audio": "pipewire"
  },
  "bootloader": "Systemd-boot",
  "kernels": ["linux"],
  "locale_config": {
    "kb_layout": "us",
    "sys_enc": "UTF-8",
    "sys_lang": "en_US"
  },
  "network_config": {
    "type": "nm"
  },
  "bluetooth": true,
  "ntp": true,
  "packages": $PACKAGES,
  "swap": true
}
EOF

echo "✓ Successfully generated $OUTPUT_FILE"
# Count packages without jq
PACKAGE_COUNT=$(grep -v '^#' "$PACKAGES_FILE" | grep -v '^$' | wc -l)
echo "Package count: $PACKAGE_COUNT"
