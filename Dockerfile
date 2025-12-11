FROM runpod/comfyui:1.2.1

# hardcoded Civitai token
ENV CIVITAI_API_TOKEN="f7908f562aa30c3b3ca991ce206c8e3a"

# download models into comfyui
RUN comfy model download --url "https://civitai.com/api/download/models/2288507?type=Model&format=SafeTensor&size=pruned&fp=fp8" --relative-path models/checkpoints --filename flux1-dev-fp8.safetensors
