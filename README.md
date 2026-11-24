# Deploy and Host HandBrake with Railway

HandBrake is the open-source video transcoder for converting video from almost any format to MP4 or MKV with modern codecs (H.264, H.265, AV1, VP9). This template runs the full HandBrake 1.11 desktop app in your browser, behind a login page, with a persistent volume, a watch folder and a web file manager for uploads and downloads.

> Community template, not affiliated with the HandBrake project or the image maintainer.

## About Hosting HandBrake

HandBrake is a desktop application. The image used here (jlesage/handbrake) runs it in a virtual X display and streams it to the browser with noVNC, so you get the real HandBrake GUI with all presets, filters, subtitles and queue features, without installing anything locally.

On Railway the GUI is protected by the image's built-in login page; the password is generated at deploy. Everything is stored on one volume: HandBrake's settings, custom presets and queue, plus folders for sources, automatic conversion and results. Upload sources and download results through the web file manager, or drop files into the watch folder and HandBrake converts them on its own with the preset you choose.

## Common Use Cases

- Convert phone, camera or screen recordings to small H.265 or AV1 files without tying up your laptop
- Batch-convert a folder of videos with one preset through the watch folder
- Rip subtitles, select audio tracks and trim videos with the familiar HandBrake GUI from any device
- Prepare web-ready MP4s (fast start) for sites, LMS platforms or social media
- Run long encodes on cloud CPUs while your own computer is off

## Dependencies for HandBrake Hosting

- HandBrake service (repo build on `jlesage/handbrake:v26.09.1`, pinned by digest)
- Railway volume at `/config`

### Deployment Dependencies

- [HandBrake documentation](https://handbrake.fr/docs/)
- [jlesage/docker-handbrake](https://github.com/jlesage/docker-handbrake) (image documentation and options)
- [Template source](https://github.com/baranberkay96/handbrake-railway)

### Implementation Details

| Service | Purpose |
|---|---|
| HandBrake | HandBrake GUI + noVNC web client + login page on port 5800, public HTTPS domain, volume at `/config` |

**First login**

1. Open the HandBrake service, Variables tab, and copy `WEB_AUTHENTICATION_USERNAME` (default `admin`) and `WEB_AUTHENTICATION_PASSWORD`.
2. Open the public domain and log in. HandBrake starts in the browser tab.
3. Upload a video: open the side panel (arrow on the left edge of the screen), choose the file manager, go to `/storage` and upload.
4. In HandBrake, open the source from `/storage`, pick a preset, set the destination to `/output` and start the encode.
5. Download the result from `/output` with the file manager.

**Folders on the volume**

| Folder | Use |
|---|---|
| `/storage` | Your source videos |
| `/watch` | Drop videos here for automatic conversion with `AUTOMATED_CONVERSION_PRESET` |
| `/output` | Converted files |
| `/trash` | Sources moved away by the automatic converter when `AUTOMATED_CONVERSION_KEEP_SOURCE=0` and `AUTOMATED_CONVERSION_USE_TRASH=1` |

All four live on the volume (`/config/storage`, `/config/watch`, ...), so they survive redeploys. The file manager only sees these folders, not HandBrake's settings or the login database.

**Security**

- The login is always on while the service has a public domain. A password that is empty, shorter than 12 or longer than 256 characters, or contains spaces locks the login with a random password; the log explains the fix.
- Railway serves the site over HTTPS; the image's login runs in its "behind a reverse proxy" mode because Railway's edge talks plain HTTP to the container.
- More users: the image supports a bcrypt password database at `/config/webauth-htpasswd` (see the image documentation).

**Resources**

HandBrake idles at roughly 150-250 MB RAM. Encoding uses every vCPU it gets and 0.5-2 GB RAM depending on resolution and codec (4K H.265 or AV1 needs the most). A Trial plan (1 GB) handles 1080p H.264 presets; use Hobby or Pro for 4K and AV1. There is no GPU on Railway, so hardware encoders (NVENC, QSV, VCN) are not available; software encoders are.

**Volume size**: videos are large. Hobby volumes start at 5 GB; increase the volume in the service settings before uploading big files.

**Upgrading**: the image is pinned by digest in `services/handbrake/Dockerfile` of the template repository. Change the tag and digest to a newer jlesage/handbrake release and redeploy; settings and files on the volume are kept.

### Why Deploy HandBrake on Railway?

Railway gives HandBrake a private, password-protected home with a persistent volume and as much CPU as your plan allows. Encodes keep running when your computer sleeps, you pay only for the minutes the CPU is busy, and you can reach the same queue from any browser.
