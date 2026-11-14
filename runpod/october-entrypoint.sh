#!/bin/bash
# Runs the October setup in the background, then starts the image's normal startup.
setsid /usr/local/bin/october-setup.sh </dev/null >/var/log/october-setup.log 2>&1 &
exec /usr/local/bin/custom-entrypoint.sh "$@"
