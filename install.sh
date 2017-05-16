#!/bin/bash

echo "==================== Installation begin ===================="
/tmp/china.sh
apt-get update
apt-get install -y \
    exuberant-ctags \
    git \
    subversion \
    mercurial \
    wget \
    inotify-tools
apt-get clean
rm -rf /var/lib/apt/lists/*

mkdir $OPENGROK_INSTANCE_BASE
mkdir $OPENGROK_INSTANCE_BASE/data
mkdir $OPENGROK_INSTANCE_BASE/etc

URL=()
while [ -z $URL ];
do
    echo "==================== Trying to fetch url ===================="
    URL=($(curl -s https://api.github.com/repos/OpenGrok/OpenGrok/releases -m5 |
        grep 'browser_download_url.*tar.gz' |
        cut -f4 -d\"))
done

# Change download address to faster mirror if we're in China
grep -qs github /etc/hosts && URL=${URL/github.com/dn-dao-github-mirror.qbox.me}
echo "==== Downloading from $URL ===="
wget $URL -qO /tmp/opengrok.tar.gz

echo "==================== Extracting OpenGrok ===================="
tar xzf /tmp/opengrok.tar.gz -C /
rm /tmp/opengrok.tar.gz
mv /opengrok-* /opengrok

echo "==================== Waiting for Tomcat ===================="
catalina.sh start
wget -q --tries inf --retry-connrefused http://127.0.0.1:8080

cd /opengrok/bin
./OpenGrok deploy
