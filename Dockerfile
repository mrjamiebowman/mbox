FROM alpine:edge
LABEL maintainer Jamie Bowman <mrjamiebowman@protonmail.com>

RUN apk update

# install app dev
RUN apk add git less openssh curl wget jq yq vim && \
    rm -rf /var/lib/apt/lists/* && \
    rm /var/cache/apk/*

RUN apk add --update --no-cache py-pip && \
    pip3 install --upgrade pip setuptools httpie && \
    rm -r /root/.cache


# install networking
RUN apk --no-cache add socat


# install containerization

# install kafka related

WORKDIR /work