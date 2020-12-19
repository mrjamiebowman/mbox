#!/usr/bin/env bash

# secret enviroment variables in Travis CI
# DOCKER_USERNAME
# DOCKER_PASSWORD
# GITHUB_NAME
# GITHUB_TOKEN

image="mrjamiebowman/mbox"
LATEST_TAG=$(git ls-remote --tags origin |awk -F \/ '{print $NF}'|grep ^1.0. |sort -Vr|head -1)

build() {
  docker build --no-cache -t ${image}:${tag} .
}

status=$(curl -sL https://hub.docker.com/v2/repositories/${image}/tags/${tag})
echo $status

if [[ ( "${status}" =~ "not found" ) || ( ${REBUILD} == "true" ) ]]; then
    build
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    docker push ${image}:v${VERSION}
fi