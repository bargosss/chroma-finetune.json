FROM runpod/comfyui:1.2.1

# Copy and set up start2.sh script
COPY start2.sh /start2.sh
RUN chmod +x /start2.sh

# Run start2.sh when container starts
CMD ["/start2.sh"]
