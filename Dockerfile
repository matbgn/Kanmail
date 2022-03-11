FROM --platform=linux/amd64 python:3.8.10-alpine3.13

LABEL maintainer="Nick Barrett, Oxygem <hello@oxygem.com>"

ARG PACKAGES='gcc make git musl-dev libc-dev libffi-dev libressl-dev zlib-dev cargo'

ADD ./requirements /opt/kanmail/requirements

RUN apk add --no-cache $PACKAGES && apk add -U tzdata \
 && pip install -r /opt/kanmail/requirements/docker.txt --no-cache-dir \
 && apk del --purge $PACKAGES

RUN cp /usr/share/zoneinfo/${TZ} /etc/localtime
RUN echo ${TZ} >  /etc/timezone

ADD . /opt/kanmail
ADD ./dist /opt/kanmail/kanmail/client/static/dist

RUN adduser --disabled-password --gecos '' kanmail

WORKDIR /opt/kanmail

RUN chown -R kanmail:kanmail /opt/kanmail

RUN mkdir -p /home/kanmail/Downloads && mkdir -p /home/kanmail/.config/kanmail \
 && chown -R kanmail:kanmail /home/kanmail

VOLUME /home/kanmail/

USER kanmail

ENTRYPOINT [ "/opt/kanmail/scripts/run.sh" ]
