FROM boky/postfix

# Use build arguments to pass environment variables
ARG MAILNAME
ARG SMTP_USER
ARG EMAIL_FROM
ARG EMAIL_TO

ENV MAILNAME=${MAILNAME}
ENV SMTP_USER=${SMTP_USER}
ENV EMAIL_FROM=${EMAIL_FROM}
ENV EMAIL_TO=${EMAIL_TO}

# Copy setup script
COPY setup.sh /config/setup.sh

# Make setup script executable
RUN chmod +x /config/setup.sh

# Run setup script at container startup
CMD ["/config/setup.sh"]
