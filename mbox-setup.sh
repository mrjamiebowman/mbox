#!/bin/bash

# ./mbox-setup.sh "kubens" "https://api.github.com/repos/ahmetb/kubectx/releases/latest" "kubens_.*_linux_x86_64.tar.gz"

# variables
APP_NAME=$1
URL=$2
FILEREGEX=$3

# env setup
mkdir -p ./downloads
mkdir -p ./downloads/$APP_NAME

echo "Download/Setup Tool: $APP_NAME"
DOWNLOAD_FILE=$(curl -s "$URL" | grep -i "$FILEREGEX\"$" | cut -d '"' -f 4)
TARBALL="$(basename -- $DOWNLOAD_FILE)"
echo "Downloading: $DOWNLOAD_FILE"
echo "File Name: $TARBALL"

# download
curl -Lo ./downloads/$TARBALL $DOWNLOAD_FILE

# extract and install into /usr/local/bin
tar -xzf ./downloads/$TARBALL -C ./downloads/$APP_NAME
chmod +x ./downloads/$APP_NAME/$APP_NAME
mv ./downloads/$APP_NAME/$APP_NAME /usr/local/bin/