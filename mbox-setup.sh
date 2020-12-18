#!/bin/bash

# mbox-setup.sh https://api.github.com/repos/ahmetb/kubectx/releases/latest "kubens_.*_linux_x86_64.tar.gz\"$"

# download
DOWNLOAD_FILE = curl -s $1 | grep -i "kubens_.*_linux_x86_64.tar.gz\"$" | cut -d '"' -f 4
wget -qi $DOWNLOAD_FILE

