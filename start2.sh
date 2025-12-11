#!/bin/bash

CHECKPOINTS_DIR="/ComfyUI/models/checkpoints"

mkdir -p "$CHECKPOINTS_DIR"

if [ -z "$MODEL_URL" ]; then
    echo "Warning: MODEL_URL is not set or is empty. Skipping model download."
else
    FILENAME=$(basename "$MODEL_URL")
    FILEPATH="$CHECKPOINTS_DIR/$FILENAME"
    
    echo "Downloading model from $MODEL_URL to $FILEPATH..."
    
    if command -v curl >/dev/null 2>&1; then
        if curl -L -o "$FILEPATH" "$MODEL_URL"; then
            echo "Download completed successfully."
        else
            echo "Error: Failed to download model from $MODEL_URL."
            rm -f "$FILEPATH"
            exit 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget -O "$FILEPATH" "$MODEL_URL"; then
            echo "Download completed successfully."
        else
            echo "Error: Failed to download model from $MODEL_URL."
            rm -f "$FILEPATH"
            exit 1
        fi
    else
        echo "Error: Neither curl nor wget is available. Cannot download model."
        exit 1
    fi
fi

for i in {1..10}; do
    echo "hello world"
done

