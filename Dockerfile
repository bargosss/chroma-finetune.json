FROM runpod/worker-comfyui:5.5.0-base

# Create entrypoint inline (no external files)
ENTRYPOINT ["/bin/bash", "-c", "\
  set -e; \
  \
  # Ensure MODEL_URL is provided
  if [ -z \"$MODEL_URL\" ]; then \
    echo 'ERROR: MODEL_URL environment variable is not set.'; \
    exit 1; \
  fi; \
  \
  MODEL_FILE=${MODEL_FILE:-chrome-finetune.safetensors}; \
  TARGET_PATH=/comfyui/models/checkpoints/$MODEL_FILE; \
  \
  # Download only if missing
  if [ ! -f \"$TARGET_PATH\" ]; then \
    echo 'Downloading model from: '$MODEL_URL; \
    comfy model download \
      --url \"$MODEL_URL\" \
      --relative-path models/checkpoints \
      --filename \"$MODEL_FILE\"; \
  else \
    echo 'Model already exists at: '$TARGET_PATH' — skipping download.'; \
  fi; \
  \
  echo 'Starting ComfyUI...'; \
  exec /start.sh \
"]
