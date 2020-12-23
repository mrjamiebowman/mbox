FROM alpine:edge
LABEL maintainer Jamie Bowman <mrjamiebowman@protonmail.com>

# env variables
ARG TZ="America/New_York"

# env: isitio
ARG ISTIO_VERSION="1.6.8"

# env: jmeter
ARG JMETER_VERSION="5.3"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV	JMETER_BIN	${JMETER_HOME}/bin
ENV	JMETER_DOWNLOAD_URL https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz

# env: mssql tools
ARG MSSQL_VERSION=17.5.2.1-1
ENV MSSQL_VERSION=${MSSQL_VERSION}

# mbox folder (documentation, scripts)
RUN mkdir -p /mbox
WORKDIR /mbox
COPY ./mbox/* .
COPY README.md /mbox/.

# build
RUN apk update
WORKDIR /root

# bashrc
COPY .bashrc .
COPY .bash_aliases .

# copy setup scripts
COPY mbox-setup.sh .
RUN chmod +x mbox-setup.sh

# mbox docs / scripts
RUN mkdir -p /mbox/docs /mbox/scripts
COPY mbox /.

# setup bash
RUN apk add --no-cache bash

# install: app dev
RUN \
    apk add --no-cache \
        ansible \
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
        mysql \
        netcat-openbsd \
        nodejs \
        npm \
        nikto \
        openssh \
        openssl \
        python3 \
        rsync \
        socat \
        terraform \
        unzip \
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
ARG DOCTL_VERSION="1.54.0"
RUN curl -L https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-amd64.tar.gz | tar -xzv && mv ~/doctl /usr/local/bin

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
# RUN \
#     ./mbox-setup.sh "kubectx" "https://api.github.com/repos/ahmetb/kubectx/releases/latest" "kubectx_.*_linux_x86_64.tar.gz" && \
#     ./mbox-setup.sh "kubens" "https://api.github.com/repos/ahmetb/kubectx/releases/latest" "kubens_.*_linux_x86_64.tar.gz"

RUN \
    curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.9.0/kind-$(uname)-amd64" && \
    chmod +x ./kind && \
    mv ./kind /usr/local/bin/kind

# install: kafka related
# RUN \
#     pip install kafka-tools

# Add Kafka Autocomplete
ARG KAFKA_AUTOCOMPLETE_VERSION=0.3
ARG KAFKA_AUTOCOMPLETE_URL="https://github.com/Landoop/kafka-autocomplete/releases/download/${KAFKA_AUTOCOMPLETE_VERSION}/kafka"
RUN mkdir -p /opt/landoop/tools/share/kafka-autocomplete \
             /opt/landoop/tools/share/bash-completion/completions \
    && wget "$KAFKA_AUTOCOMPLETE_URL" \
            -O /opt/landoop/tools/share/kafka-autocomplete/kafka \
    && wget "$KAFKA_AUTOCOMPLETE_URL" \
            -O /opt/landoop/tools/share/bash-completion/completions/kafka

# install: mssql tools
WORKDIR /tmp

# Installing system utilities
RUN apk add --no-cache curl gnupg --virtual .build-dependencies -- && \
    # Adding custom MS repository for mssql-tools and msodbcsql
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_${MSSQL_VERSION}_amd64.apk && \
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_${MSSQL_VERSION}_amd64.apk && \
    # Verifying signature
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_${MSSQL_VERSION}_amd64.sig && \
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_${MSSQL_VERSION}_amd64.sig && \
    # Importing gpg key
    curl https://packages.microsoft.com/keys/microsoft.asc  | gpg --import - && \
    gpg --verify msodbcsql17_${MSSQL_VERSION}_amd64.sig msodbcsql17_${MSSQL_VERSION}_amd64.apk && \
    gpg --verify mssql-tools_${MSSQL_VERSION}_amd64.sig mssql-tools_${MSSQL_VERSION}_amd64.apk && \
    # Installing packages
    echo y | apk add --allow-untrusted msodbcsql17_${MSSQL_VERSION}_amd64.apk mssql-tools_${MSSQL_VERSION}_amd64.apk && \
    # Deleting packages
    apk del .build-dependencies && rm -f msodbcsql*.sig mssql-tools*.apk

# entrypoint
WORKDIR /work