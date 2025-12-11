#!/bin/bash
set -e

if [ "$_MODEL_DOWNLOADED" = "1" ]; then
    exec "$@"
fi

export _MODEL_DOWNLOADED=1

CHECKPOINTS_DIR="/workspace/runpod-slim/ComfyUI/models/checkpoints"

if [ -z "$MODEL_URL" ]; then
    echo "[entrypoint] Warning: MODEL_URL is not set or is empty. Skipping model download."
else
    URL_WITHOUT_QUERY="${MODEL_URL%%\?*}"
    FILENAME=$(basename "$URL_WITHOUT_QUERY")
    
    if [ -z "$FILENAME" ] || [ "$FILENAME" = "/" ]; then
        FILENAME="model.safetensors"
    fi
    
    FILEPATH="$CHECKPOINTS_DIR/$FILENAME"
    export MODEL_DOWNLOAD_URL="$MODEL_URL"
    export MODEL_DOWNLOAD_PATH="$FILEPATH"
fi

echo "[entrypoint] Starting base image startup script..."

if [ $# -eq 0 ]; then
    if [ -f "/start.sh" ]; then
        if [ -n "$MODEL_DOWNLOAD_URL" ] && [ -n "$MODEL_DOWNLOAD_PATH" ]; then
            echo "[entrypoint] Model download will happen after ComfyUI is initialized..."
            (
                while [ ! -d "/workspace/runpod-slim/ComfyUI" ]; do
                    sleep 2
                done
                sleep 5
                if [ ! -f "$MODEL_DOWNLOAD_PATH" ]; then
                    echo "[entrypoint] Downloading model from $MODEL_DOWNLOAD_URL to $MODEL_DOWNLOAD_PATH..."
                    mkdir -p "$(dirname "$MODEL_DOWNLOAD_PATH")"
                    if command -v curl >/dev/null 2>&1; then
                        curl -L --progress-bar -o "$MODEL_DOWNLOAD_PATH" "$MODEL_DOWNLOAD_URL" 2>&1 && echo "[entrypoint] Model download completed successfully." || echo "[entrypoint] Model download failed."
                    elif command -v wget >/dev/null 2>&1; then
                        wget --progress=bar:force -O "$MODEL_DOWNLOAD_PATH" "$MODEL_DOWNLOAD_URL" 2>&1 && echo "[entrypoint] Model download completed successfully." || echo "[entrypoint] Model download failed."
                    fi
                else
                    echo "[entrypoint] Model file already exists at $MODEL_DOWNLOAD_PATH. Skipping download."
                fi
            ) &
        fi
        exec /start.sh
    else
        echo "[entrypoint] Error: No command provided and /start.sh not found."
        exit 1
    fi
else
    exec "$@"
fi

