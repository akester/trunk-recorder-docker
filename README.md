# Trunk Recorder

This is a package of https://github.com/TrunkRecorder/trunk-recorder, but this
includes:

* MQTT stats plugin: https://github.com/TrunkRecorder/tr-plugin-mqtt
* A number of packages needed for Broadcastify calls.
* A few missing libraries that my setup needed (fdk-aac namely)

This is not a small image, but should be a nearly complete set up for a Trunk
Recorder instance that wants to ship recordings to all the places.

## Tags

This follows the Trunk Recorder tag format for the most part:

* `latest` - Latest tagged version
* `edge` - Trunk Recorder's development branch.  A "nightly" build but it
  updates once a week.
* Released versions are tagged for specific versions as well.

All images are built every Tuesday to get any upstream changes and updates in
the base Docker containers.

## Usage

This should be used the same as the normal Trunk Recoder container.  Here's an
example Docker Compose config you can use:

```
services:
  recorder:
    image: akester/trunk-recorder
    container_name: trunk-recorder
    restart: always
    privileged: true
    devices:
      - "/dev/bus/usb:/dev/bus/usb:rwm"
    volumes:
      - /var/run/dbus:/var/run/dbus 
      - /var/run/avahi-daemon/socket:/var/run/avahi-daemon/socket
      - ./recorder:/app
      - ./recordings/recordings/tr:/recordings
```

## Docs

More docs for this are coming soon at
https://docs.aikester.com/containers/trunk-recorder

## Building

This image is built via Packer and will build multiple architectures.  Because
of the compiliation steps, I _highly_ reccomend just using some ARM hardware to
do the ARM builds.

It also has a Makefile, so on a x86 desktop, you can just run `make`.  `make
build-arm` will build the ARM variant.

## Mirror

If you're looking at this repo at
https://github.com/akester/trunk-recorder-docker, know that it's a mirror of my
local code repository.  This repo is monitored though, so any pull requests or
issues will be seen.
