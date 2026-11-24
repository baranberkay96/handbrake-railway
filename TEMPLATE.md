# HandBrake 1.11 Video Transcoder in Your Browser: Railway template spec

## Listing

| Field | Value |
|---|---|
| Name | **HandBrake 1.11 Video Transcoder in Your Browser** |
| Description | HandBrake GUI in a browser tab with login, watch folder and file manager. (73 chars) |
| Category | Other |
| Icon | `https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/handbrake.svg` |
| Repo | `baranberkay96/handbrake-railway`, root `/services/handbrake` |

## Base market templates

None on the marketplace (empty `_market`). Built from jlesage/handbrake and our browser-app experience (117-chromium-browser, 135-firefox-browser).

### Design decisions

- jlesage/handbrake v26.09.1 (HandBrake 1.11.2), pinned by digest. Its init (`/init` + cinit) has no PID-1 check, so it works under Railway's podman-init without the s6 workaround the linuxserver images need.
- Login: the image's own login page (`WEB_AUTHENTICATION=1`, `WEB_AUTHENTICATION_ALLOW_INSECURE=1` because Railway's edge speaks HTTP to the container). Forced on while a public domain exists; invalid password locks with a random one (8.29).
- One volume (`/config`, Rule 3b): settings plus `storage/`, `watch/`, `output/`, `trash/`. Railway ignores the base image's `VOLUME` lines, so `/output` etc. do not exist and upstream `55-handbrake.sh` aborts ("Output folder '/output' doesn't exist", first test). `railway-start` links `/storage`, `/watch`, `/output`, `/trash` to the volume folders before `/init`; the converter uses `find -follow`, so links work.
- Web file manager restricted to those four folders (uploads/downloads without host mounts).
- VNC TCP port disabled (`VNC_LISTENING_PORT=-1`); the browser uses the unix socket via nginx websockify.
- Healthcheck `/site.webmanifest` (served without login once nginx is up; nginx depends on Xvnc and webauth).

## Pinned versions

| Component | Pin | Checked |
|---|---|---|
| jlesage/handbrake | `v26.09.1@sha256:6f3a121e…` (HandBrake 1.11.2, 2026-09-22) | 2026-11-24 |

## Services

| Service | Source | Healthcheck | Domain | Volume |
|---|---|---|---|---|
| HandBrake | repo `/services/handbrake` | `/site.webmanifest`, 600 s | public, 5800 | `/config` |

Restart `ALWAYS`. One replica (volume).

## Resource profile

Measured 2026-11-24: idle 0.14-0.22 GB (~$2/month), 1080p Very Fast encode ~0.25 GB and all vCPUs; H.265/AV1/4K presets need more (0.5-2 GB). Minimum plan: Trial for 1080p H.264; Hobby for 4K/H.265/AV1. Volume grows with media ($0.15/GB-month).

## Verification checklist

1. Deploy SUCCESS, `/site.webmanifest` 200, `/` redirects to `/login` without a session.
2. Log in with the generated credentials; HandBrake window visible.
3. Upload a file through the file manager to `/watch`; automatic converter writes to `/output`.
4. Redeploy: settings and files persist.
5. Password `abc`: deploy succeeds, login locked, log explains.

## Open questions

- No GPU on Railway: hardware encoders unavailable (documented).
- Upload size through the file manager is bounded by nginx/browser; very large sources may need several minutes.
