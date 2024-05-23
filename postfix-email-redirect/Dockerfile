FROM boky/postfix

# Install rsyslog
RUN apt-get update && apt-get install -y rsyslog

# Copy setup script
COPY setup.sh /config/setup.sh

# Make setup script executable
RUN chmod +x /config/setup.sh

# Copy rsyslog config
COPY rsyslog.conf /etc/rsyslog.conf

# Run setup script
RUN /config/setup.sh

# Start rsyslog and Postfix in the foreground
CMD service rsyslog start && postfix start-fg
