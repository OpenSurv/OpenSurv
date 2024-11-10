# Opensurv - Open Source Surveillance (<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=QPJU9K2KZ8D94" target="_blank" rel="nofollow"><img src="https://www.paypal.com/en_US/i/btn/x-click-but21.gif" alt="" /></a>)

## What is Opensurv?

Opensurv is a free application that transforms your [verified device](#Verified-hardware-list) into a dedicated device to monitor video streams or images.  

![Screenshot](examples/4streams.png)

## Verified hardware list
This list contains known working hardware/software combinations.  
If you successfully tested hardware not on the list yet, then please add it to the list or make a GitHub issue about it.
### Fully functional:
| Hardware               | CPU/GPU                   | Arch    | OS               | Notes                                                                                                                                                                                                                                   |
|------------------------|---------------------------|---------|------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ASUS ExpertCenter PN42 | Intel N100                | x86_64  | Ubuntu 24.04 LTS | - VESA mountable in the box <br /> - Passive cooling <br /> - Low power (~10Watt) <br /> - Powerful, can render more streams at the same time than a Rpi5                                                                               |
### Testing in progress:
| Hardware               | CPU/GPU                   | Arch    | OS               | Notes                                                                                                                                                                                                                                   |
|------------------------|---------------------------|---------|------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Raspberry Pi 5 2GB     | Cortex A76/Video Core VII | arm64   | Ubuntu 24.04 LTS | - VESA mountable with extra accessoires <br /> - Passive cooling <br /> - Low power (~10Watt) <br /> - Use `freeform_advanced_mpv_options: "--vo=gpu-next"` <br /> - More details [here](https://github.com/OpenSurv/opensurv/discussions/3) |  


## Features
##### Self-healing and health monitoring including watchdogs
- Every stream will be monitored by an external watchdog process. If the stream gets killed somehow, the watchdog will try to restart the stream/process. This gives you a very robust surveillance screen.
- Stream up/down detection and auto-repositioning of connectable streams on the screen layout. 
  For example: if you stop a camera (or just stop the server on the camera), Opensurv will detect this and will recalculate/redraw the screen with the still available streams. The same is true if a previous unconnectable stream becomes connectable. All without any user interaction.

##### Automatically position streams (no manual coordinates calculation needed)
- Auto-calculate coordinates for every stream monitored.
- If you are not happy with the autocalculations, you [can](examples/force_coordinates_example.md) customize them yourself. 

##### Rotation of screens (autorotate or with keyboard control)
- You can configure multiple screens and cycle between them in an automated way or via the keyboard. 
- In the case of dual monitors, you can configure multiple screens to be cycled between for each monitor.

##### Multiple types of streams
- You can also specify "image streams" to monitor images next to or instead of camera streams. The images will be auto-updated if they change remotely.

##### Dual monitor support
- Opensurv will auto-detect if a second monitor is connected at boot and will automatically start the configured screens for the second monitor.

## How to get started
In short: The idea is to connect your [verified device](#Verified-hardware-list) to a monitor and tell Opensurv which stream(s) and screen(s) it should monitor or cycle between. Opensurv will auto-calculate all the rest.
- Get a monitor or a TV (or 2)
- Get a [verified device](#Verified-hardware-list) dedicated for Opensurv
- Install a verified [operating system](#Verified-hardware-list) on the device
- On the freshly installed operating system, log in as a user and git clone this repository: 
  - `git clone https://github.com/opensurv/opensurv`
- Move into the folder `cd opensurv`
- OPTIONAL: checkout a specific branch, for example `git checkout v4_latest`, if you want to override the default version on master
- Run `sudo ./install.sh`
- Enjoy the demo showcase

## Configuration

Opensurv has the following config files
- `/etc/opensurv/general.yml` => General config, mostly not needed to touch this.
- `/etc/opensurv/monitor1.yml`  => Define screens and streams used for the first monitor.
- `/etc/opensurv/monitor2.yml`  => Define screens and streams used for the second monitor.
Which monitor will be monitor1 or monitor2 depends on which port you plug it into.   
If you only plug in one monitor, then only one of the config files will be read (monitor1.yml or monitor2.yml).

A screen consists of multiple streams.
On a monitor, you can define multiple screens which can be cycled between.

For full config explanation with all possible options, consult the config files in /etc/opensurv after install.

## URL sources

#### file://
This is a path on disk; by default, a video file is expected. This video file will then be played in an endless loop.
If used with imageurl: true, then an image file is expected. If the image changes on disk, then Opensurv will also reload the stream with the new image.

TIP: If an external program rotates the images on disk, then Opensurv can thus be used as a frontend for a digital picture frame.

#### http:// and https://
This is a remote location with a video file or video stream.
If used with imageurl: true, then an image file is expected. If the remote image changes, then Opensurv will also reload the stream with the new image.

TIP: This can be used as part of a digital signage setup: several Opensurv clients can be steered centrally by changing the image(s) at the central location.
Opensurv will autodetect interruptions and try to restore the stream.
#### rtsp:// and rtmp://
This is a remote location with a video stream. Opensurv will do its best to monitor the stream, it will autodetect interruptions and try to restore the stream.

## How to update Opensurv to new version <a name="how-to-update"></a>
- `cd opensurv; git pull`
- OPTIONAL: checkout a specific branch, for example `git checkout v4_latest`, if you want to override the default version on master
- Run `sudo ./install.sh` (The installer will ask if you want to preserve your current config file)
- `systemctl restart lightdm.service`

## Release notes

See [RELEASE_NOTES](https://github.com/opensurv/opensurv/releases)

## Placeholder images
After installation, you may change the placeholder images to something you like.
- /home/opensurv/lib/images/connecting.png is shown when a camera stream is starting up.
- /home/opensurv/lib/images/placeholder.png is shown on empty squares.
- /home/opensurv/lib/images/noconnectable.png is shown full screen when no connectable streams are detected for the current active screen in case multiple are cycled between.
- /home/opensurv/lib/images/loading.png is shown full screen when loading the next screen in a cycle.
- `systemctl restart lightdm.service`

## Opensurv in operation

If you used the install.sh script, you can configure your streams in /etc/opensurv. After editing the config files, you need to restart Opensurv (`systemctl restart lightdm.service`) for the changes to take effect.

If you are connected via keyboard/keypad, you can force the next screen by pressing and holding n or space (or keypad "+") for some seconds in case multiple screens were defined (this takes longer depending on the number of unconnectable streams, and they thus need to wait for timeout; keep holding until the screen changes. Note, you can change probe_timeout per camera stream if needed).

Keys F1 to F12 (or keypad 0 to 9) will force the equal numbered screen to be shown onscreen (this takes longer depending on the number of unconnectable streams, and they thus need to wait for timeout; keep holding until the screen changes. Note, you can change probe_timeout per camera stream if needed).

Disable rotation (as in pause rotation, as in fix the current monitored screen) dynamically during runtime by pressing "p" (or keypad "*") to pause or "r" (or "," or keypad ".") to resume/rotate. This overrides the disable_autorotation option if this has been set in the config file.

In case of dual monitors, then the screens on both monitors will be controlled at the same time.


## Troubleshooting

- I advise you to test your URLs in mpv (command line) first. It should work before attempting to use them in Opensurv.

- If you used the install.sh script, logs are created at /home/opensurv/logs/. You can use them for troubleshooting. Enable DEBUG logging for very detailed output of what is going on. Switch INFO to DEBUG in /etc/opensurvc/logging.yml and restart opensurv.

- If you are connected via keyboard/keypad, you can stop Opensurv by pressing and holding q (or backspace or keypad "/") (this can take some seconds).

- To manage the screen without rebooting, use systemctl:
  - `sudo systemctl stop lightdm.service` to stop the screen.
  - `sudo systemctl start lightdm.service` to start the screen.
  - `tail -F /home/opensurv/logs/main.log` to see last logs.

- If you want to stream RTSP over TCP, please add `freeform_advanced_mpv_options: "--rtsp-transport=tcp"` to the stream configured in the config files in /etc/opensurv.
  See in /etc/opensurv for examples.
  If you have a "smearing" effect, this option may resolve it. 

- Significantly reduce latency on a stream by adding `freeform_advanced_mpv_options:"--profile=low-latency --untimed"` to the stream configured in the config files in /etc/opensurv.

## MISC

- Join the community on https://github.com/OpenSurv/opensurv/discussions.<br/>
- Bug tracking https://github.com/OpenSurv/opensurv/issues.<br/>