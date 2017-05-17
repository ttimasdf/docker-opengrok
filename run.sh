#!/bin/bash

export JAVA_OPTS="-Xmx8192m -server"
export OPENGROK_FLUSH_RAM_BUFFER_SIZE="-m 256"
sysctl -w fs.inotify.max_user_watches=8192000

TARBALL=/tmp/opengrok.tar.gz
if [ ! -f $OPENGROK_INSTANCE_BASE/.deployed.lock ]; then
  echo "=============== Initiating OpenGrok Instance ==============="
  if [[ ! "$1" =~ '^https?://' ]]; then
    URL=()
    while [ -z $URL ];
    do
        printf "Trying to fetch url...."
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

  echo "==================== Extracting OpenGrok ===================="
  tar xzf $TARBALL -C /
  rm $TARBALL
  mv /opengrok-* /opengrok

  cd /opengrok/bin
  ./OpenGrok deploy
  touch $OPENGROK_INSTANCE_BASE/.deployed.lock
fi

if [ -n "$FORCE_REINDEX_ON_BOOT" -o ! -e $OPENGROK_INSTANCE_BASE/data/timestamp ]; then
  echo "================ Running first-time indexing ================"
  OPENGROK_WEBAPP_CFGADDR=none /opengrok/bin/OpenGrok index /src
fi


# ... and we keep running the indexer to keep the container on
echo "================ Waiting for source updates... ================"

{
  if [ $INOTIFY_NOT_RECURSIVE ]; then
    touch $OPENGROK_INSTANCE_BASE/reindex
    INOTIFY_CMDLINE="inotifywait -m -e CLOSE_WRITE $OPENGROK_INSTANCE_BASE/reindex"
  else
    INOTIFY_CMDLINE="inotifywait -mr -e CLOSE_WRITE /src"
  fi

  $INOTIFY_CMDLINE | while read f; do
    echo "===================== Updating index ====================="
    printf "...Due to file changed %s\n" "$f"
    cd /opengrok/bin
    ./OpenGrok index /src
  done
} &

echo "==================== Waiting for Tomcat ===================="
echo "Waiting for service become available... [this may take long]"
{
  wget -nv --tries inf --retry-connrefused http://127.0.0.1:8080 -O /dev/null &&
  echo "==================== Bootstrap Completed ===================="
} &
catalina.sh run
