#!/bin/bash

URLS_PATTERN='https?:(?:(?!p5p|pkg|src).)*(.tar.gz|\.zip|.tar.gz.zip)'

FILE=/tmp/releases.txt
curl 'https://api.github.com/repos/OpenGrok/OpenGrok/releases' -o $FILE

tags=($(grep 'tag_name' $FILE | cut -f4 -d\"))
urls=($(grep -Po $URLS_PATTERN $FILE))

function geturl() {
    local tag="$1"
    for url in "${urls[@]}"; do
        [[ "$url" =~ "$tag" ]] && echo $url && return
    done
}

for tag in "${tags[@]}"; do
    url=$(geturl $tag)
    echo "==================== Building version $tag ===================="
    [[ -z "$url" ]] && continue
    echo "Injecting url $url"
    line="RUN /usr/local/bin/install \"${url}\""
    sed "s#^RUN /usr/local/bin/install*#${line}#" Dockerfile > Dockerfile.$tag
    docker build -f "Dockerfile.$tag" -t $REPO:$tag --build-arg CI=$CI \
        --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
        --build-arg VCS_REF=`git rev-parse --short HEAD` \
        --build-arg VERSION="$tag" . || { echo "Ver $tag docker build failed"; exit 1; }
done
