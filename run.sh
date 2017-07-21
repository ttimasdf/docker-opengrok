#!/bin/bash

export JAVA_OPTS="-Xmx8192m -server"
export OPENGROK_FLUSH_RAM_BUFFER_SIZE="-m 256"
sysctl -w fs.inotify.max_user_watches=8192000

cd /opengrok/bin
if [ ! -f $OPENGROK_TOMCAT_BASE/webapps/source.war ]; then
  ./OpenGrok deploy
fi

if [ -n "$FORCE_REINDEX_ON_BOOT" -o ! -e $OPENGROK_INSTANCE_BASE/data/timestamp ]; then
  echo "================ Running first-time indexing ================"
  OPENGROK_WEBAPP_CFGADDR=none ./OpenGrok index /src
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
