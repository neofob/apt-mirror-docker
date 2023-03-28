# Building apt-mirror from sources

FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PKGS="apt-utils cronie make perl wget rsync xz-utils bzip2 tini" \
    APT_USER="apt-mirror" \
    APT_GID=1000 \
    APT_UID=1000
RUN apt-get update && apt-get upgrade -yq && apt-get dist-upgrade -yq && apt-get install -yq ${PKGS}
RUN addgroup --gid ${APT_GID} ${APT_USER} && adduser --gid ${APT_GID} --uid ${APT_UID} ${APT_USER}
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime
RUN apt-get autoclean -yq && apt-get autoremove -yq

RUN mkdir /apt-mirror
WORKDIR /apt-mirror
COPY ./apt-mirror /apt-mirror/
COPY ./.perltidyrc /apt-mirror/
COPY ./Makefile /apt-mirror/
COPY ./mirror.list /etc/apt/
COPY ./postmirror.sh /var/spool/apt-mirror/var/

RUN make
RUN make install

COPY ./crontab/apt-mirror /etc/cron.d/apt-mirror
RUN chown root:root /etc/cron.d/apt-mirror && chmod 0644 /etc/cron.d/apt-mirror

# We run crontab service as root but switch to apt-mirror user for apt-mirror
ENTRYPOINT ["/usr/bin/tini", "-v", "--", "/usr/sbin/crond", "-n", "-x", "load"]
