FROM alpine:edge
LABEL maintainer Jamie Bowman <mrjamiebowman@protonmail.com>

# env variables
ARG TZ="America/New_York"

ARG JMETER_VERSION="5.3"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV	JMETER_BIN	${JMETER_HOME}/bin
ENV	JMETER_DOWNLOAD_URL https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz

RUN apk update
WORKDIR /root

# setup bash
RUN apk add --no-cache bash

# install: app dev
RUN \
    apk add --no-cache \
        curl \
        git \
        gcc \
        go \
        html2text \
        httpie \
        jq \
        less \
        make \
        musl-dev \
        openssh \       
        wget \        
        yq \
        vim

# install: dotnet
RUN \ 
    curl -Lo dotnet-install.sh https://dot.net/v1/dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    ./dotnet-install.sh -c 5.0 && \
    export DOTNET_ROOT=/root/.dotnet

ENV PATH /root/.dotnet:$PATH

# install: go
ENV GOROOT /usr/lib/go
ENV GOPATH /go
ENV PATH /go/bin:$PATH

RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin

# install: glide
RUN apk add --no-cache py-pip && \
    pip3 install --upgrade pip setuptools && \
    rm -r /root/.cache

# install: jmeter
RUN \
    mkdir -p /opt && \
    mkdir -p /tmp/jmeter && \
    curl -Lo /tmp/jmeter/apache-jmeter-${JMETER_VERSION}.tgz ${JMETER_DOWNLOAD_URL} && \
	tar -xzf /tmp/jmeter/apache-jmeter-${JMETER_VERSION}.tgz -C /opt && \
	rm -rf /tmp/jmeter

ENV PATH /opt/apache-jmeter-${JMETER_VERSION}/bin:$PATH

# install: networking
RUN apk --no-cache add socat

# install: containerization

# install: kafka related

# path variable

WORKDIR /work