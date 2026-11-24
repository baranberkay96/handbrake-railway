# NOTICE: HandBrake 1.11 Video Transcoder in Your Browser template

This is a community template. It is not affiliated with or endorsed by the HandBrake project, Jocelyn Le Sage (image maintainer) or Railway. HandBrake is a trademark of its respective owners.

## Components

| Component | Source | License | How it is used |
|---|---|---|---|
| HandBrake 1.11.2 | https://github.com/HandBrake/HandBrake | GPL-2.0 | Inside the base image, unmodified |
| jlesage/handbrake v26.09.1 | https://github.com/jlesage/docker-handbrake, image `jlesage/handbrake:v26.09.1@sha256:6f3a121e235d34e7299080e8cbac5284060e942fb2b137f777e2521fb7af65ae` | MIT (image build files); bundled software under its own licenses | Base image |
| jlesage/baseimage-gui v4.14.0 (noVNC, Xvnc, nginx, web login) | https://github.com/jlesage/docker-baseimage-gui | MIT; noVNC MPL-2.0; TigerVNC GPL-2.0; nginx BSD-2-Clause | Inside the base image |
| HandBrake icon | https://github.com/homarr-labs/dashboard-icons (`svg/handbrake.svg`) | Apache-2.0 (collection); logo belongs to the HandBrake project | Marketplace icon |

## Files written for this template

`services/handbrake/Dockerfile`, `railway-start.sh` and `55-railway-folders.sh` were written for this template (no upstream file copied) and are offered under the MIT License. They set Railway defaults through the image's documented environment variables, validate the login variables and create the media folders on the volume.

## Upstream checked (2026-11-24)

- jlesage/docker-handbrake README and `Dockerfile` at tag `v26.09.1` (HandBrake 1.11.2, baseimage-gui alpine-3.20-v4.14.0, volumes, environment variables, automatic video converter).
- jlesage/docker-baseimage `rootfs/init` (no PID-1 check; cinit supervisor), `helpers/take-ownership`, `cont-init.d/85-take-config-ownership.sh`.
- jlesage/docker-baseimage-gui README (WEB_AUTHENTICATION, WEB_AUTHENTICATION_ALLOW_INSECURE for TLS-terminating proxies, WEB_FILE_MANAGER, VNC_LISTENING_PORT=-1), nginx `default_site.conf`, `include/auth.conf`, `include/vnc.conf` (`/site.webmanifest` is served without login and is used as healthcheck).

## Market templates reviewed

The `_market` folder for HandBrake was empty: no HandBrake template was found on the Railway marketplace on 2026-11-24.
