#!/bin/bash

echo "==================== Installation begin ===================="
env
loc -u
apt-get update
apt-get install -y \
    exuberant-ctags \
    git \
    subversion \
    mercurial \
    wget \
    zip \
    inotify-tools
apt-get clean
rm -rf /var/lib/apt/lists/*

mkdir $OPENGROK_INSTANCE_BASE
mkdir $OPENGROK_INSTANCE_BASE/data
mkdir $OPENGROK_INSTANCE_BASE/etc
echo {} > $OPENGROK_INSTANCE_BASE/data/statistics.json

