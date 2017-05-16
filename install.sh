#!/bin/bash
mkdir $OPENGROK_INSTANCE_BASE
mkdir $OPENGROK_INSTANCE_BASE/data
mkdir $OPENGROK_INSTANCE_BASE/etc

URL=()
while [ -z $URL ];
do
    echo "Trying to fetch url"
    URL=($(curl -s https://api.github.com/repos/OpenGrok/OpenGrok/releases -m5 |
        grep 'browser_download_url.*tar.gz' |
        cut -f4 -d\"))
done

# Change download address to faster mirror if we're in China
grep -qs github /etc/hosts && URL=${URL/github.com/dn-dao-github-mirror.qbox.me}
echo "Downloading from $URL"
wget $URL -qO /tmp/opengrok.tar.gz

echo "Extracting OpenGrok"
tar xzf /tmp/opengrok.tar.gz -C /
rm /tmp/opengrok.tar.gz
mv opengrok-* opengrok

cd /opengrok/bin
./OpenGrok deploy
