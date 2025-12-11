FROM runpod/comfyui:1.2.1

# Copy local checkpoints into the container's ComfyUI checkpoint directory
COPY checkpoints/ /workspace/ComfyUI/models/checkpoints/
