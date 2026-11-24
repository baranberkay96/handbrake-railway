#!/bin/sh
# Railway start wrapper for HandBrake: checks the deploy-form variables, then
# runs the image's /init. Never exits because of a variable value (STANDARD 8.29).
set -u

log() { echo "railway-start: $*"; }
random_secret() { tr -dc 'A-Za-z0-9' </dev/urandom 2>/dev/null | head -c 40; }

# --- Port: Railway's healthcheck and the public domain use PORT. ---
case "${PORT:-}" in
    ''|*[!0-9]*) log "WARNING: PORT='${PORT:-}' is not a number, using 5800"; PORT=5800 ;;
esac
if [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
    log "WARNING: PORT=${PORT} is out of range, using 5800"; PORT=5800
fi
export PORT WEB_LISTENING_PORT="$PORT"

# --- Login: always on while the service has a public domain. ---
if [ "${WEB_AUTHENTICATION:-1}" != 1 ] && [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
    log "WARNING: WEB_AUTHENTICATION=${WEB_AUTHENTICATION:-} is ignored: the service has a public domain, the login stays on."
fi
if [ "${WEB_AUTHENTICATION:-1}" = 1 ] || [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
    export WEB_AUTHENTICATION=1 WEB_AUTHENTICATION_ALLOW_INSECURE=1
fi

user="${WEB_AUTHENTICATION_USERNAME:-}"
if ! printf '%s' "$user" | grep -Eq '^[A-Za-z0-9._@-]{1,64}$'; then
    log "WARNING: WEB_AUTHENTICATION_USERNAME is empty or has characters other than letters, digits and . _ @ -; using 'admin'"
    user=admin
fi
pass="${WEB_AUTHENTICATION_PASSWORD:-}"
len=$(printf '%s' "$pass" | wc -c | tr -d ' ')
if [ "$len" -lt 12 ] || [ "$len" -gt 256 ] || printf '%s' "$pass" | grep -q '[[:space:][:cntrl:]]'; then
    log "WARNING: WEB_AUTHENTICATION_PASSWORD is empty, shorter than 12 or longer than 256 characters, or contains spaces."
    log "         The login is LOCKED with a random password nobody knows."
    log "         Fix: set a password of 12-256 characters without spaces in the Variables tab and redeploy."
    pass="$(random_secret)"
fi
export WEB_AUTHENTICATION_USERNAME="$user" WEB_AUTHENTICATION_PASSWORD="$pass"
unset pass

# --- Fixed numeric settings the image would refuse. ---
for var in DISPLAY_WIDTH DISPLAY_HEIGHT; do
    eval "val=\${$var:-}"
    case "$val" in
        ''|*[!0-9]*) [ -n "$val" ] && log "WARNING: $var='$val' is not a number, using the image default"; unset "$var" ;;
    esac
done

# --- Media folders on the volume; /storage, /watch, /output and /trash link there. ---
for dir in storage watch output trash; do
    mkdir -p "/config/${dir}" 2>/dev/null || log "WARNING: cannot create /config/${dir}"
    if [ -L "/${dir}" ]; then
        continue
    fi
    if [ -d "/${dir}" ]; then
        rmdir "/${dir}" 2>/dev/null || { log "WARNING: /${dir} is not empty, leaving it as is"; continue; }
    fi
    ln -s "/config/${dir}" "/${dir}" || log "WARNING: cannot link /${dir}"
done
rm -rf /config/lost+found 2>/dev/null || true

log "HandBrake GUI on port ${PORT} with login user '${user}'; media folders under /config"
exec /init "$@"
