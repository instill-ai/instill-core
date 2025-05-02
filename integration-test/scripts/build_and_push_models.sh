#!/bin/sh
set -e

MODEL_INVENTORY_DIR="$1"
REGISTRY_URL="$2"

# Check if instill command is available
if ! command -v instill >/dev/null 2>&1; then
    echo "Error: 'instill' command not found. Please ensure instill-sdk is properly installed." >&2
    exit 1
fi

SDK_PATH=$(python3 -c 'import instill; import os.path; print(os.path.dirname(os.path.dirname(instill.__file__)))' 2>/dev/null || echo "")
for dir in "${MODEL_INVENTORY_DIR}"/*/; do
    folder_name=$(basename "${dir}")
    echo "Building ${folder_name}..."
    cd "${dir}"
    instill build "admin/${folder_name}:dev" -e "${SDK_PATH}"
    instill push "admin/${folder_name}:dev" -u "${REGISTRY_URL}"
done
