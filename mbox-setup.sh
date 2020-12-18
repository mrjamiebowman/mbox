#!/bin/bash

# ./mbox-setup.sh "kubens" "https://api.github.com/repos/ahmetb/kubectx/releases/latest" "kubens_.*_linux_x86_64.tar.gz"

# variables
APP_NAME=$1
URL=$2
FILEREGEX=$3

# download
echo "Download/Setup Tool: $APP_NAME"
DOWNLOAD_FILE=$(curl -s "$URL" | grep -i "$FILEREGEX\"$" | cut -d '"' -f 4)
TARBALL="$(basename -- $DOWNLOAD_FILE)"
echo "Downloading: $DOWNLOAD_FILE"
echo "File Name: $TARBALL"
curl -Lo $TARBALL $DOWNLOAD_FILE
rm $TARBALL
tar -xzf $TARBALL
chmod +x $APP_NAME
mv $APP_NAME /usr/local/bin/
