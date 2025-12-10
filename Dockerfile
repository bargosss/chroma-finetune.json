# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.0-base

# Ensure no automatic build-time download happens; runtime wrapper downloads only when both vars are provided.
ENV MODEL_URL=""
ENV MODEL_FILENAME=""

# Create a single-file runtime wrapper that:
# - ensures model dirs exist
# - removes common fallback files (so they won't act as a fallback)
# - downloads the requested model only if MODEL_URL and MODEL_FILENAME are set
# - then starts the original start script (or comfy) as the image expects
RUN mkdir -p /usr/local/bin && \
    cat > /usr/local/bin/start-no-fallback.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail

echo "[start-no-fallback] wrapper starting..."

# Make sure ComfyUI model directories are present so startup checks won't think they're missing.
mkdir -p /comfyui/models/checkpoints /comfyui/models/vae /comfyui/models/unet /comfyui/models/clip

# If user explicitly provided a model URL + filename, download that model now.
if [ -n "${MODEL_URL:-}" ] && [ -n "${MODEL_FILENAME:-}" ]; then
  echo "[start-no-fallback] MODEL_URL and MODEL_FILENAME provided; downloading requested model: ${MODEL_FILENAME}"
  comfy model download --url "${MODEL_URL}" --relative-path models/checkpoints --filename "${MODEL_FILENAME}"
else
  echo "[start-no-fallback] No MODEL_URL/MODEL_FILENAME provided — skipping user-model download."

  # Remove a small set of known fallback files that some images or scripts may include.
  # Add any other filenames you observe to this list.
  FALLBACK_FILES=(
    "/comfyui/models/checkpoints/flux1-dev-fp8.safetensors"
    "/comfyui/models/checkpoints/flux1-dev.safetensors"
    "/comfyui/models/checkpoints/sd_xl_base_1.0.safetensors"
    "/comfyui/models/checkpoints/sd3_medium_incl_clips_t5xxlfp8.safetensors"
  )

  for f in "${FALLBACK_FILES[@]}"; do
    if [ -f "$f" ]; then
      echo "[start-no-fallback] Removing fallback file: $f"
      rm -f "$f"
    fi
  done
fi

echo "[start-no-fallback] Finished preparation. Executing main start."

# Execute the upstream start script if present; otherwise attempt to exec comfy directly.
if [ -x "/start.sh" ]; then
  exec /start.sh "$@"
else
  exec comfy "$@"
fi
SH
RUN chmod +x /usr/local/bin/start-no-fallback.sh

# install custom nodes into comfyui
# (no custom registry-verified nodes in this workflow)

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/

# Use our wrapper as the container CMD so it runs at container start.
CMD ["/usr/local/bin/start-no-fallback.sh"]
