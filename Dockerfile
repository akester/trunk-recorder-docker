

WORKDIR /src/trunk-recorder-prometheus

COPY . .

WORKDIR /src/trunk-recorder-prometheus/build

RUN mv /etc/gnuradio/conf.d/gnuradio-runtime.conf /tmp/gnuradio-runtime.conf && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
        git \
        cmake \
        make \
        libssl-dev \
        build-essential \
        gnuradio-dev \
        libuhd-dev \
        libcurl4-openssl-dev \
        libsndfile1-dev && \
    cmake .. && make install && \
    apt-get purge -y git cmake make libssl-dev build-essential gnuradio-dev libuhd-dev libcurl4-openssl-dev libsndfile1-dev && \
    mv /tmp/gnuradio-runtime.conf /etc/gnuradio/conf.d/gnuradio-runtime.conf && \
    rm -rf /var/lib/apt/lists/*

RUN rm -rf /src/trunk-recorder-prometheus

WORKDIR /app
