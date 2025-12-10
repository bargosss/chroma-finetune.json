# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.0-base

# install custom nodes into comfyui
# (no custom registry-verified nodes in this workflow)

# download models into comfyui
RUN comfy model download --url ${MODEL_URL} --relative-path models/checkpoints --filename ${MODEL_FILENAME}

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/
