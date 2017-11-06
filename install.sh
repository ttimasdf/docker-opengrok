#!/bin/bash

echo "==================== Installation begin ===================="

mkdir $OPENGROK_INSTANCE_BASE
mkdir $OPENGROK_INSTANCE_BASE/data
mkdir $OPENGROK_INSTANCE_BASE/etc
echo {} > $OPENGROK_INSTANCE_BASE/data/statistics.json

echo "=============== Downloading $1 ==============="
TARBALL=/tmp/opengrok.tar.gz

if [[ "$1" = 'latest' ]]; then
    URL=()
    while [ -z $URL ];
    do
        printf "Trying to fetch latest release"
        URL=($(curl -s https://api.github.com/repos/OpenGrok/OpenGrok/releases -m5 |
            grep 'browser_download_url.*tar.gz' |
            cut -f4 -d\"))
        [ -n $URL ] && echo "Success" || echo "Failed"
    done
elif [[ "$1" =~ ^https?:// ]]; then
    URL="$1"
else
    echo "Skipping OpenGrok binary link retrieval."
    exit
fi

echo "Downloading from $URL"
wget $URL -qO $TARBALL

[[ "$URL" =~ .zip ]] && mv $TARBALL $TARBALL.zip && unzip -p $TARBALL.zip > $TARBALL
tar xzf $TARBALL -C / || { echo "Download failed! exiting.."; exit 1; }
echo "Extracting OpenGrok...."
rm $TARBALL*
mv /opengrok-* /opengrok
