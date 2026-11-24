#!/bin/sh
# Railway: create the media folders on the /config volume (one volume per
# service). Runs as root during the image's init, before ownership of /config
# is handed to USER_ID/GROUP_ID by 85-take-config-ownership.sh.
set -eu
for dir in media watch output trash; do
    mkdir -p "/config/${dir}"
done
rm -rf /config/lost+found 2>/dev/null || true
echo "media folders ready: /config/media (sources), /config/watch (automatic conversion), /config/output (results)"
