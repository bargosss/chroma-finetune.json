#!/bin/bash
set -e

exec > >(tee -a /proc/1/fd/1) 2>&1

CHECKPOINTS_DIR="/ComfyUI/models/checkpoints"

echo "[start2.sh] Starting script execution..."
mkdir -p "$CHECKPOINTS_DIR"

if [ -z "$MODEL_URL" ]; then
    echo "[start2.sh] Warning: MODEL_URL is not set or is empty. Skipping model download."
else
    FILENAME=$(basename "$MODEL_URL")
    FILEPATH="$CHECKPOINTS_DIR/$FILENAME"
    
    echo "[start2.sh] Downloading model from $MODEL_URL to $FILEPATH..."
    
    if command -v curl >/dev/null 2>&1; then
        if curl -L --progress-bar -o "$FILEPATH" "$MODEL_URL" 2>&1; then
            echo "[start2.sh] Download completed successfully."
        else
            echo "[start2.sh] Error: Failed to download model from $MODEL_URL."
            rm -f "$FILEPATH"
            exit 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget --progress=bar:force -O "$FILEPATH" "$MODEL_URL" 2>&1; then
            echo "[start2.sh] Download completed successfully."
        else
            echo "[start2.sh] Error: Failed to download model from $MODEL_URL."
            rm -f "$FILEPATH"
            exit 1
        fi
    else
        echo "[start2.sh] Error: Neither curl nor wget is available. Cannot download model."
        exit 1
    fi
fi

echo "[start2.sh] Script execution completed. Continuing with main process..."
for i in {1..10}; do
    echo "hello world"
done

