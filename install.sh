#!/bin/bash

echo "==================== Installation begin ===================="
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

echo "=============== Initiating OpenGrok Instance ==============="
TARBALL=/tmp/opengrok.tar.gz

if [[ ! "$1" =~ '^https?://' ]]; then
    URL=()
    while [ -z $URL ];
    do
        printf "Trying to fetch latest release"
        URL=($(curl -s https://api.github.com/repos/OpenGrok/OpenGrok/releases -m5 |
            grep 'browser_download_url.*tar.gz' |
            cut -f4 -d\"))
        [ -n $URL ] && echo "Success" || echo "Failed"
    done
fi

# Change download address to a faster mirror if we're in China
[ "$(loc)" = "China" ] && URL=${URL/github.com/dn-dao-github-mirror.qbox.me}
echo "Downloading from $URL"
wget $URL -qO $TARBALL

echo "Extracting OpenGrok...."
tar xzf $TARBALL -C /
rm $TARBALL
mv /opengrok-* /opengrok

