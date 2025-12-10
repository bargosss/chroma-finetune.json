# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.0-base

# install custom nodes into comfyui
# (no custom registry-verified nodes in this workflow)

# hardcoded Civitai token
ENV CIVITAI_API_TOKEN="f7908f562aa30c3b3ca991ce206c8e3a"

# disable ComfyUI-Manager auto-loading to prevent infinite loop
ENV COMFYUI_MANAGER_DISABLE_AUTO_LOAD="1"
ENV DISABLE_AUTO_LOAD="1"

# download models into comfyui
RUN comfy model download --url "https://civitai.com/api/download/models/2288507?type=Model&format=SafeTensor&size=pruned&fp=fp8" --relative-path models/checkpoints --filename chrome-finetune.safetensors

# fix ComfyUI-Manager infinite loop by disabling it
RUN if [ -f "/comfyui/custom_nodes/ComfyUI-Manager/__init__.py" ]; then \
        mv /comfyui/custom_nodes/ComfyUI-Manager/__init__.py /comfyui/custom_nodes/ComfyUI-Manager/__init__.py.disabled || true; \
    fi

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/
