#!/bin/bash

# China specific optimization
LOC=""

if [ -z "$LOC" ]; then
    LOC=$(curl -s http://ip-api.com/csv|cut -d, -f2)
    if [ ! "$CI" = "true" ]; then
        sed -ie "s/^LOC.*/LOC='$LOC'/" "$0"
    fi
fi

if [ "$LOC" = "China" -a $# -gt 0 ];then
	echo "=============== Optimizing for Chinese network.. ==============="

	wget -q https://mirrors.ustc.edu.cn/repogen/conf/debian-http-4-jessie -O /etc/apt/sources.list
	rm -R /etc/apt/sources.list.d
fi
echo $LOC
