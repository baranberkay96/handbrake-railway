# syntax=docker/dockerfile:1
#
# HandBrake 1.11.2 in a browser tab, for Railway.
#
# Base: jlesage/handbrake v26.09.1 (HandBrake 1.11.2 on jlesage/baseimage-gui
# alpine-3.20-v4.14.0: Xvnc + noVNC + nginx, cinit supervisor). Its /init has no
# PID-1 check, so it runs under Railway's podman-init unchanged.
# Pin checked 2026-11-24 on Docker Hub (amd64 manifest digest, pushed 2026-09-22).
ARG HANDBRAKE_IMAGE=jlesage/handbrake:v26.09.1@sha256:6f3a121e235d34e7299080e8cbac5284060e942fb2b137f777e2521fb7af65ae
FROM ${HANDBRAKE_IMAGE}

# Railway defaults (variables set on the service win, except where the start
# script enforces a safe value):
#  - The image's own login page (WEB_AUTHENTICATION) protects the GUI.
#    Railway's edge terminates HTTPS and talks plain HTTP to the container, so
#    the image's "insecure" switch is required; browsers only ever use HTTPS.
#  - VNC port off: the browser GUI talks to Xvnc through a unix socket.
#  - Everything lives on the single Railway volume at /config: settings,
#    presets, queue, and the storage/, watch/, output/ and trash/ folders.
#    Railway ignores the base image's VOLUME lines (the /storage, /output
#    folders do not exist there), so railway-start links /storage, /watch,
#    /output and /trash to those folders before the image's init runs.
ENV PORT=5800 \
    WEB_LISTENING_PORT=5800 \
    VNC_LISTENING_PORT=-1 \
    WEB_AUTHENTICATION=1 \
    WEB_AUTHENTICATION_ALLOW_INSECURE=1 \
    WEB_FILE_MANAGER=1 \
    WEB_FILE_MANAGER_ALLOWED_PATHS=/storage,/watch,/output,/trash,/config/storage,/config/watch,/config/output,/config/trash \
    KEEP_APP_RUNNING=1 \
    DARK_MODE=1

COPY --chmod=0755 railway-start.sh /usr/local/bin/railway-start

EXPOSE 5800
ENTRYPOINT ["/usr/local/bin/railway-start"]
