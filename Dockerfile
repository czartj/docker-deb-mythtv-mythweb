FROM czartj/docker-deb-mythtv:latest

RUN \
    apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends -t stable-backports mythweb

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/*

# Add our files...
ADD rootfs /

ENTRYPOINT ["/init"]

