#!/bin/sh

# Start nginx in foreground
exec nginx -g 'daemon off;'
