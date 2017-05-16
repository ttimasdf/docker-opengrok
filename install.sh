#!/bin/sh
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

echo "Downloading from $URL"
wget $URL -O /tmp/opengrok.tar.gz

echo "Extracting OpenGrok"
tar xzf /tmp/opengrok.tar.gz -C /
rm /tmp/opengrok.tar.gz
mv opengrok-* opengrok

cd /opengrok/bin
./OpenGrok deploy
