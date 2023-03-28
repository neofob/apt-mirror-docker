# Building apt-mirror from sources

FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PKGS="apt-utils cron make perl wget rsync xz-utils bzip2"
RUN apt-get update && apt-get dist-upgrade -yq && apt-get install -yq ${PKGS}
RUN adduser apt-mirror
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime
RUN apt-get autoclean -yq && apt-get autoremove -yq

WORKDIR /apt-mirror
COPY ./apt-mirror /apt-mirror
COPY ./.perltidyrc /apt-mirror
COPY ./Makefile /apt-mirror
COPY ./mirror.list /etc/apt
COPY ./postmirror.sh /apt-mirror

RUN make
RUN make install

COPY crontab /etc/cron.d

# We run crontab service as root but switch to apt-mirror user for apt-mirror
ENTRYPOINT service cron start && crontab /etc/cron.d/* && su apt-mirror -c /usr/local/bin/apt-mirror && tail -F /var/spool/apt-mirror/var/cron.log
