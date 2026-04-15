FROM czartj/docker-deb-mythtv:latest

RUN \
    apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends mythweb

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/*

# Add our files...
ADD rootfs /
# don't need a default page...
RUN rm /etc/apache2/sites-enabled/000-default.conf

ENTRYPOINT ["/init"]

