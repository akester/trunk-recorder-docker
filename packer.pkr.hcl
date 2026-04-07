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
  default = "5.2"
}

source "docker" "tr-amd64" {
  commit = true
  image  = "robotastic/trunk-recorder:latest"
  platform = "linux/amd64"
}

source "docker" "tr-arm64" {
  commit = true
  image  = "robotastic/trunk-recorder:latest"
  platform = "linux/arm64"
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

  # Build prometheus
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline           = [
      "set -e",
      "set -x",
      "apt-get install -y curl git cmake build-essential file zlib1g-dev",
    ]
    inline_shebang   = "/bin/bash -e"
  }
  provisioner "shell" {
    inline           = [
      "set -e",
      "set -x",
      "git clone https://github.com/jupp0r/prometheus-cpp -b v${var.prometheus_version} /tmp/prometheus-cpp",
      "cd /tmp/prometheus-cpp",
      "git submodule init && git submodule update",
      "mkdir build && cd build",
      "cmake -DCPACK_GENERATOR=DEB -DBUILD_SHARED_LIBS=ON -DENABLE_PUSH=OFF -DENABLE_COMPRESSION=ON ..",
      "cmake --build . --target package --parallel $(nproc)",
      "mv prometheus-cpp_*.deb /prometheus-cpp.deb",
      "cd -",
      "rm -rf /tmp/prometheus-cpp",
      "dpkg -i /prometheus-cpp.deb",
    ]
    inline_shebang   = "/bin/bash -e"
  }

  # # Build FDK-AAC
  # provisioner "shell" {
  #   environment_vars = [
  #     "DEBIAN_FRONTEND=noninteractive",
  #     "DEBIAN_PRIORITY=critical"
  #   ]
  #   inline           = [
  #     "set -e",
  #     "set -x",
  #     "apt-get install -y curl git cmake build-essential autoconf automake autotools-dev libtool",
  #   ]
  #   inline_shebang   = "/bin/bash -e"
  # }
  # provisioner "shell" {
  #   inline           = [
  #     "set -e",
  #     "set -x",
  #     "git clone https://github.com/mstorsjo/fdk-aac /tmp/fdk-aac",
  #     "cd /tmp/fdk-aac",
  #     "autoreconf -fiv",
  #     "./configure --enable-shared",
  #     "make -j4",
  #     "make install && ldconfig",
  #   ]
  #   inline_shebang   = "/bin/bash -e"
  # }

  # # Deps needed for Broadcastify calls
  # provisioner "shell" {
  #   environment_vars = [
  #     "DEBIAN_FRONTEND=noninteractive",
  #     "DEBIAN_PRIORITY=critical"
  #   ]
  #   inline           = [
  #     "set -e",
  #     "set -x",
  #     "apt-get install -y libssl-dev libcurl4-openssl-dev sox chrony",
  #   ]
  #   inline_shebang   = "/bin/bash -e"
  # }

  # # Deps needed for our uploader
  # provisioner "shell" {
  #   environment_vars = [
  #     "DEBIAN_FRONTEND=noninteractive",
  #     "DEBIAN_PRIORITY=critical"
  #   ]
  #   inline           = [
  #     "set -e",
  #     "set -x",
  #     "apt-get install -y python3-minimal lame",
  #   ]
  #   inline_shebang   = "/bin/bash -e"
  # }

  # # Build Trunk Recorder
  # provisioner "shell" {
  #   environment_vars = [
  #     "DEBIAN_FRONTEND=noninteractive",
  #     "DEBIAN_PRIORITY=critical"
  #   ]
  #   inline           = [
  #     "set -e",
  #     "set -x",
  #     "apt-get install -y  git cmake make libssl-dev build-essential gnuradio-dev libuhd-dev libcurl4-openssl-dev libsndfile1-dev libboost-log-dev libboost-random-dev",
  #   ]
  #   inline_shebang   = "/bin/bash -e"
  # }
  # provisioner "file" {
  #   source = "gnuradio-runtime.conf"
  #   destination = "/tmp/gnuradio-runtime.conf"
  # }
  # provisioner "shell" {
  #   inline           = [
  #     "set -e",
  #     "set -x",
  #     "git clone https://github.com/TrunkRecorder/trunk-recorder.git -b v${var.tr_version} /tmp/trunk-recorder",
  #     "mkdir /tmp/trunk-recorder-build && cd /tmp/trunk-recorder-build",
  #     "cmake ../trunk-recorder",
  #     "make",
  #     "make install",
  #     "mv /tmp/gnuradio-runtime.conf /etc/gnuradio/conf.d/gnuradio-runtime.conf",
  #   ]
  #   inline_shebang   = "/bin/bash -e"
  # }

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
