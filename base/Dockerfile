FROM debian:jessie
MAINTAINER Miguel Mejias

ENV METEOR_ALLOW_SUPERUSER 1

ENV METEORD_DIR /opt/meteord
COPY scripts $METEORD_DIR

RUN bash $METEORD_DIR/lib/install_base.sh
RUN bash $METEORD_DIR/lib/cleanup.sh

EXPOSE 80
ENTRYPOINT bash $METEORD_DIR/run_app.sh
