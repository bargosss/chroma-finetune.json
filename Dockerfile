FROM runpod/comfyui:1.2.1

# Copy entrypoint script that downloads model before starting ComfyUI
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Use entrypoint to download model, then exec the base image's CMD
ENTRYPOINT ["/entrypoint.sh"]
