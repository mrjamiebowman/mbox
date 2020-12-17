FROM alpine:edge
LABEL maintainer Jamie Bowman <mrjamiebowman@protonmail.com>

RUN apk update

# install: app dev
RUN apk add git less openssh curl wget jq yq vim html2text make musl-dev go && \
    rm -rf /var/lib/apt/lists/* && \
    rm /var/cache/apk/*

# install: dotnet

# configure: go
ENV GOROOT /usr/lib/go
ENV GOPATH /go
ENV PATH /go/bin:$PATH

RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin

# Install Glide
RUN go get -u github.com/Masterminds/glide/...

RUN apk update

RUN apk add --update --no-cache py-pip && \
    pip3 install --upgrade pip setuptools httpie && \
    rm -r /root/.cache


# install: networking
RUN apk --no-cache add socat


# install: containerization

# install: kafka related

WORKDIR /work