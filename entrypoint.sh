#!/bin/bash
set -e

CHECKPOINTS_DIR="/workspace/runpod-slim/ComfyUI/models/checkpoints"

if [ -z "$MODEL_URL" ]; then
    echo "[entrypoint] Warning: MODEL_URL is not set or is empty. Skipping model download."
else
    mkdir -p "$CHECKPOINTS_DIR"
    FILENAME=$(basename "$MODEL_URL")
    FILEPATH="$CHECKPOINTS_DIR/$FILENAME"
    
    echo "[entrypoint] Downloading model from $MODEL_URL to $FILEPATH..."
    
    if command -v curl >/dev/null 2>&1; then
        if curl -L --progress-bar -o "$FILEPATH" "$MODEL_URL" 2>&1; then
            echo "[entrypoint] Download completed successfully."
        else
            echo "[entrypoint] Error: Failed to download model from $MODEL_URL."
            rm -f "$FILEPATH"
            exit 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget --progress=bar:force -O "$FILEPATH" "$MODEL_URL" 2>&1; then
            echo "[entrypoint] Download completed successfully."
        else
            echo "[entrypoint] Error: Failed to download model from $MODEL_URL."
            rm -f "$FILEPATH"
            exit 1
        fi
    else
        echo "[entrypoint] Error: Neither curl nor wget is available. Cannot download model."
        exit 1
    fi
fi

echo "[entrypoint] Model download check complete. Starting base image startup script..."
exec "$@"

