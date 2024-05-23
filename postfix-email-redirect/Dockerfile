FROM boky/postfix

# Copy setup script
COPY setup.sh /config/setup.sh

# Make setup script executable
RUN chmod +x /config/setup.sh

# Run setup script
RUN /config/setup.sh

# Start Postfix in the foreground
CMD ["postfix", "start-fg"]
