#!/bin/bash
set -e

if [ "$_MODEL_DOWNLOADED" = "1" ]; then
    exec "$@"
fi

export _MODEL_DOWNLOADED=1

CHECKPOINTS_DIR="/workspace/runpod-slim/ComfyUI/models/checkpoints"

MODEL_DOWNLOAD_URL=""
MODEL_DOWNLOAD_PATH=""

if [ -z "$MODEL_URL" ]; then
    echo "[entrypoint] Warning: MODEL_URL is not set or is empty. Skipping model download."
else
    echo "[entrypoint] MODEL_URL is set: $MODEL_URL"
    URL_WITHOUT_QUERY="${MODEL_URL%%\?*}"
    FILENAME=$(basename "$URL_WITHOUT_QUERY")
    
    if [ -z "$FILENAME" ] || [ "$FILENAME" = "/" ]; then
        FILENAME="model.safetensors"
    fi
    
    FILEPATH="$CHECKPOINTS_DIR/$FILENAME"
    MODEL_DOWNLOAD_URL="$MODEL_URL"
    MODEL_DOWNLOAD_PATH="$FILEPATH"
    export MODEL_DOWNLOAD_URL
    export MODEL_DOWNLOAD_PATH
    echo "[entrypoint] Will download to: $FILEPATH"
fi

echo "[entrypoint] Starting base image startup script..."
echo "[entrypoint] DEBUG: MODEL_DOWNLOAD_URL='$MODEL_DOWNLOAD_URL'"
echo "[entrypoint] DEBUG: MODEL_DOWNLOAD_PATH='$MODEL_DOWNLOAD_PATH'"
echo "[entrypoint] DEBUG: Number of args: $#"
echo "[entrypoint] DEBUG: MODEL_DOWNLOAD_URL check: [ -n '$MODEL_DOWNLOAD_URL' ] = $([ -n \"$MODEL_DOWNLOAD_URL\" ] && echo \"true\" || echo \"false\")"
echo "[entrypoint] DEBUG: MODEL_DOWNLOAD_PATH check: [ -n '$MODEL_DOWNLOAD_PATH' ] = $([ -n \"$MODEL_DOWNLOAD_PATH\" ] && echo \"true\" || echo \"false\")"

# Always attempt background download if URL and path are present (arg count/order irrelevant)
if [ -n "$MODEL_DOWNLOAD_URL" ] && [ -n "$MODEL_DOWNLOAD_PATH" ]; then
    echo "[entrypoint] Model download will happen after ComfyUI is initialized..."
    echo "[entrypoint] Model URL: $MODEL_DOWNLOAD_URL"
    echo "[entrypoint] Target path: $MODEL_DOWNLOAD_PATH"
    
    (
        exec > >(tee -a /proc/1/fd/1) 2>&1
        echo "[entrypoint] Background download process started (PID: $$)"
        echo "[entrypoint] Waiting for ComfyUI directory to be created..."
        COUNTER=0
        while [ ! -d "/workspace/runpod-slim/ComfyUI" ] && [ $COUNTER -lt 300 ]; do
            sleep 2
            COUNTER=$((COUNTER + 2))
            if [ $((COUNTER % 10)) -eq 0 ]; then
                echo "[entrypoint] Still waiting for ComfyUI directory... ($COUNTER seconds)"
            fi
        done
        
        if [ ! -d "/workspace/runpod-slim/ComfyUI" ]; then
            echo -e "[entrypoint] \e[31mERROR: ComfyUI directory not found after waiting. Download aborted.\e[0m"
            exit 1
        fi
        
        echo "[entrypoint] ComfyUI directory found. Waiting additional 15 seconds for full initialization..."
        sleep 15
        
        if [ ! -f "$MODEL_DOWNLOAD_PATH" ]; then
            echo "[entrypoint] Starting model download from $MODEL_DOWNLOAD_URL to $MODEL_DOWNLOAD_PATH..."
            mkdir -p "$(dirname "$MODEL_DOWNLOAD_PATH")"
            
            if command -v curl >/dev/null 2>&1; then
                if curl -L --progress-bar -o "$MODEL_DOWNLOAD_PATH" "$MODEL_DOWNLOAD_URL" 2>&1; then
                    echo "[entrypoint] Model download completed successfully!"
                else
                    echo -e "[entrypoint] \e[31mERROR: Model download failed!\e[0m"
                    exit 1
                fi
            elif command -v wget >/dev/null 2>&1; then
                if wget --progress=bar:force -O "$MODEL_DOWNLOAD_PATH" "$MODEL_DOWNLOAD_URL" 2>&1; then
                    echo "[entrypoint] Model download completed successfully!"
                else
                    echo -e "[entrypoint] \e[31mERROR: Model download failed!\e[0m"
                    exit 1
                fi
            else
                echo -e "[entrypoint] \e[31mERROR: Neither curl nor wget available for download!\e[0m"
                exit 1
            fi
        else
            echo "[entrypoint] Model file already exists at $MODEL_DOWNLOAD_PATH. Skipping download."
        fi
    ) &
    DOWNLOAD_PID=$!
    echo "[entrypoint] Background download process started with PID: $DOWNLOAD_PID"
    disown $DOWNLOAD_PID 2>/dev/null || true
else
    echo -e "[entrypoint] \e[31mERROR: MODEL_DOWNLOAD_URL or MODEL_DOWNLOAD_PATH not set. Skipping background download.\e[0m"
fi

# After scheduling download, run /start.sh if present and no args; otherwise exec args
if [ $# -eq 0 ]; then
    if [ -f "/start.sh" ]; then
        exec /start.sh
    else
        echo -e "[entrypoint] \e[31mERROR: No command provided and /start.sh not found. Download may have been skipped.\e[0m"
        exit 1
    fi
else
    exec "$@"
fi
