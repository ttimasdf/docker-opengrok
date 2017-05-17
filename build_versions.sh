#!/bin/bash

URLS_PATTERN='https?:(?:(?!p5p|pkg|src).)*(.tar.gz|\.zip|.tar.gz.zip)'

FILE=/tmp/releases.txt
curl 'https://api.github.com/repos/OpenGrok/OpenGrok/releases' -o $FILE

tags=($(grep 'tag_name' $FILE | cut -f4 -d\"))
urls=($(grep -Po $URLS_PATTERN $FILE))

function geturl() {
    local tag="$1"
    for url in "${urls[@]}"; do
        [[ "$url" = *"$tag"* ]] && echo $url && return
    done
}

for tag in "${tags[@]}"; do
    url=$(geturl $tag)
    echo $tag $url
    [[ -z "$url" ]] && continue
    line="ENTRYPOINT [\"/usr/local/bin/run\", \"${url}\"]"
    sed "s%^ENTRYPOINT.*%${line}%" Dockerfile > Dockerfile.$tag
    docker build -f "Dockerfile.$tag" -t $REPO:$tag .
done
