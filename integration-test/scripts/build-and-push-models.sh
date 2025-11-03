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

# Read model IDs from inventory.json
INVENTORY_FILE="${MODEL_INVENTORY_DIR}/inventory.json"
if [ ! -f "${INVENTORY_FILE}" ]; then
    echo "Error: Inventory file not found at ${INVENTORY_FILE}" >&2
    exit 1
fi

# Extract model IDs from inventory.json and build/push only those models
MODEL_IDS=$(jq -r '.[].id' "${INVENTORY_FILE}")

for model_id in ${MODEL_IDS}; do
    model_dir="${MODEL_INVENTORY_DIR}/${model_id}"
    if [ ! -d "${model_dir}" ]; then
        echo "Warning: Model directory not found for ${model_id}, skipping..." >&2
        continue
    fi

    echo "Building ${model_id}..."
    cd "${model_dir}"
    instill build "admin/${model_id}:dev" -e "${SDK_PATH}"
    instill push "admin/${model_id}:dev" -u "${REGISTRY_URL}"
done
