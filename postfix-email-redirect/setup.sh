#!/bin/bash

# Generate virtual file from environment variables
echo "${EMAIL_FROM} ${EMAIL_TO}" > /config/virtual

# Update Postfix configuration to use virtual alias map
postconf -e "virtual_alias_maps = hash:/etc/postfix/virtual"

# Copy the virtual file to Postfix directory
cp /config/virtual /etc/postfix/virtual

# Create the virtual map database
postmap /etc/postfix/virtual

# Restart Postfix to apply changes
service postfix restart
