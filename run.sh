#!/bin/sh

export JAVA_OPTS="-Xmx8192m -server"
export OPENGROK_FLUSH_RAM_BUFFER_SIZE="-m 256"
sysctl -w fs.inotify.max_user_watches=8192000

if [ -n "$FORCE_REINDEX_ON_BOOT" -o ! -e $OPENGROK_INSTANCE_BASE/data/timestamp ]; then
  echo "================ Running first-time indexing ================"
  cd /opengrok/bin
  ./OpenGrok index /src
fi

# ... and we keep running the indexer to keep the container on
echo "================ Waiting for source updates... ================"
touch $OPENGROK_INSTANCE_BASE/reindex

if [ $INOTIFY_NOT_RECURSIVE ]; then
  INOTIFY_CMDLINE="inotifywait -m -e CLOSE_WRITE $OPENGROK_INSTANCE_BASE/reindex"
else
  INOTIFY_CMDLINE="inotifywait -mr -e CLOSE_WRITE /src"
fi

$INOTIFY_CMDLINE | while read f; do
  printf "*** %s\n" "$f"
  echo "*** Updating index"
  cd /opengrok/bin
  ./OpenGrok index /src
done
