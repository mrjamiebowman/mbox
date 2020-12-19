FROM alpine:edge
LABEL maintainer Jamie Bowman <mrjamiebowman@protonmail.com>

# env variables
ARG TZ="America/New_York"

# env: jmeter
ARG JMETER_VERSION="5.3"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV	JMETER_BIN	${JMETER_HOME}/bin
ENV	JMETER_DOWNLOAD_URL https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz

# env: isitio
ARG ISTIO_VERSION="1.6.8"

# build
RUN apk update
WORKDIR /root

# bashrc
COPY .bashrc .
COPY .bash_aliases .

# copy setup scripts
COPY mbox-setup.sh .
RUN chmod +x mbox-setup.sh

# setup bash
RUN apk add --no-cache bash

# install: app dev
RUN \
    apk add --no-cache \
        ca-certificates \
        coreutils \
        curl \
        docker \
        docker-compose \
        libc6-compat \
        git \
        gcc \
        go \
        html2text \
        httpie \
        jq \
        less \
        make \
        musl-dev \
        nikto \
        openssh \
        openssl \
        rsync \
        socat \
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

# install: vscode server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# install: go
ENV GOROOT /usr/lib/go
ENV GOPATH /go
ENV PATH /go/bin:$PATH
RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin

# install: glide
RUN apk add --no-cache py-pip && \
    pip3 install --upgrade pip setuptools && \
    rm -r /root/.cache

# install: doctl
#RUN curl -sL https://github.com/digitalocean/doctl/releases/download/v<version>/doctl-<version>-linux-amd64.tar.gz | tar -xzv && \

# install: jmeter
RUN \
    mkdir -p /opt && \
    mkdir -p /tmp/jmeter && \
    curl -Lo /tmp/jmeter/apache-jmeter-${JMETER_VERSION}.tgz ${JMETER_DOWNLOAD_URL} && \
	tar -xzf /tmp/jmeter/apache-jmeter-${JMETER_VERSION}.tgz -C /opt && \
	rm -rf /tmp/jmeter

ENV PATH /opt/apache-jmeter-${JMETER_VERSION}/bin:$PATH

# kubectl
RUN \
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"  && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# helm
RUN \
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh

# linkerd
RUN curl -sL https://run.linkerd.io/install | sh
ENV PATH /root/.linkerd2/bin:$PATH

# istio
RUN \
    curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} TARGET_ARCH=x86_64 sh - && \
    chmod +x istio-${ISTIO_VERSION}/bin/istioctl && \
    mv istio-${ISTIO_VERSION}/bin/istioctl /usr/local/bin/

# kubectx / kubens
RUN \
    ./mbox-setup.sh "kubectx" "https://api.github.com/repos/ahmetb/kubectx/releases/latest" "kubectx_.*_linux_x86_64.tar.gz" && \
    ./mbox-setup.sh "kubens" "https://api.github.com/repos/ahmetb/kubectx/releases/latest" "kubens_.*_linux_x86_64.tar.gz"
    
RUN \
    curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.9.0/kind-$(uname)-amd64" && \
    chmod +x ./kind && \
    mv ./kind /usr/local/bin/kind

# install: kafka related

# path variable

WORKDIR /work