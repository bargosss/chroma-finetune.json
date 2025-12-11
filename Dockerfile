FROM runpod/comfyui:1.2.1

# hardcoded Civitai token (user-requested)
# ENV CIVITAI_API_TOKEN="f7908f562aa30c3b3ca991ce206c8e3a"

# Download model into ComfyUI; red ERROR on failure.
#RUN set -e; \
#    mkdir -p /opt/ComfyUI/models/checkpoints; \
#    curl -fL \
#        -H "Authorization: Bearer $CIVITAI_API_TOKEN" \
#        "https://civitai.com/api/download/models/2288507?type=Model&format=SafeTensor&size=pruned&fp=fp8" \
#        -o "/opt/ComfyUI/models/checkpoints/flux1-dev-fp8.safetensors" \
#    || { printf '\033[31mERROR\033[0m model download failed\n'; exit 1; }
