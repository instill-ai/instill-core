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

# Only process dummy-cls folder
DUMMY_CLS_DIR="${MODEL_INVENTORY_DIR}/dummy-cls"
if [ ! -d "$DUMMY_CLS_DIR" ]; then
    echo "Error: dummy-cls directory not found in ${MODEL_INVENTORY_DIR}" >&2
    exit 1
fi

echo "Building dummy-cls..."
cd "$DUMMY_CLS_DIR"
instill build "admin/dummy-cls:dev" -e "${SDK_PATH}"
instill push "admin/dummy-cls:dev" -u "${REGISTRY_URL}"
