variable "version" {
  type    = string
  default = "dev"
}

variable "prometheus_version" {
  type    = string
  default = "1.2.4"
}

variable "tr_version" {
  type    = string
  default = "master"
}

source "docker" "tr-amd64" {
  commit = true
  image  = "ubuntu:24.04"
  platform = "linux/amd64"
  changes = [
    "CMD [\"/bin/sh\", \"-c\", \"trunk-recorder --config=/app/config.json\"]",
    "WORKDIR \"/app\"",
  ]
}

source "docker" "tr-arm64" {
  commit = true
  image  = "ubuntu:24.04"
  platform = "linux/arm64"
  changes = [
    "CMD [\"/bin/sh\", \"-c\", \"trunk-recorder --config=/app/config.json\"]",
    "WORKDIR \"/app\"",
  ]
}

build {
  sources = [
    "source.docker.tr-amd64",
    "source.docker.tr-arm64"
  ]

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline           = [
      "set -e",
      "set -x",
      "apt-get update",
      "apt-get -y dist-upgrade",
    ]
    inline_shebang   = "/bin/bash -e"
  }

  # Common tools that can be bigger
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline           = [
      "set -e",
      "set -x",
      "apt-get install -y curl git cmake build-essential",
    ]
    inline_shebang   = "/bin/bash -e"
  }

  # Build FDK-AAC
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline           = [
      "set -e",
      "set -x",
      "apt-get install -y --no-install-recommends --no-install-suggests curl git cmake build-essential autoconf automake autotools-dev libtool",
    ]
    inline_shebang   = "/bin/bash -e"
  }
  provisioner "shell" {
    inline           = [
      "set -e",
      "set -x",
      "git clone https://github.com/mstorsjo/fdk-aac.git /tmp/fdk-aac",
      "cd /tmp/fdk-aac",
      "autoreconf -fiv",
      "./configure --enable-shared",
      "make -j4",
      "make install && ldconfig",
    ]
    inline_shebang   = "/bin/bash -e"
  }

  # Deps needed for Broadcastify calls
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline           = [
      "set -e",
      "set -x",
      "apt-get install -y --no-install-recommends --no-install-suggests libssl-dev libcurl4-openssl-dev sox chrony",
    ]
    inline_shebang   = "/bin/bash -e"
  }

  # Deps needed for our uploader
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline           = [
      "set -e",
      "set -x",
      "apt-get install -y --no-install-recommends --no-install-suggests python3-minimal lame",
    ]
    inline_shebang   = "/bin/bash -e"
  }

  # Deps for MQTT
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline           = [
      "set -e",
      "set -x",
      "apt-get install -y --no-install-recommends --no-install-suggests libpaho-mqtt-dev libpaho-mqttpp-dev",
    ]
    inline_shebang   = "/bin/bash -e"
  }

  # Build Trunk Recorder
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline           = [
      "set -e",
      "set -x",
      "apt-get install -y --no-install-recommends --no-install-suggests apt-transport-https build-essential ca-certificates ffmpeg git gnupg gnuradio gnuradio-dev gr-osmosdr libuhd-dev libboost-all-dev libcurl4-openssl-dev libgmp-dev libhackrf-dev liborc-0.4-dev libpthread-stubs0-dev libssl-dev libusb-dev pkg-config software-properties-common cmake libsndfile1-dev gr-osmosdr libosmosdr0",
    ]
    inline_shebang   = "/bin/bash -e"
  }
  provisioner "shell" {
    inline           = [
      "set -e",
      "set -x",
      "git clone https://github.com/TrunkRecorder/trunk-recorder.git -b ${var.tr_version} /tmp/trunk-recorder",
      "cd /tmp/trunk-recorder/user_plugins",
      "git clone https://github.com/TrunkRecorder/tr-plugin-mqtt",
      "mkdir /tmp/trunk-build && cd /tmp/trunk-build",
      "cmake ../trunk-recorder",
      "make -j4",
      "make install"
    ]
    inline_shebang   = "/bin/bash -e"
  }
  
  post-processor "docker-tag" {
    repository = "akester/trunk-recorder"
    tags = [
      "${source.name}-${var.version}",
    ]
  }
}

packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}
