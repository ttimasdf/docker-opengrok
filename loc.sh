#!/bin/sh

# China specific optimization
LOC=""

if [ -z "$LOC" ]; then
    LOC=$(curl -s http://ip-api.com/csv|cut -d, -f2)
    sed -ie "s/^LOC.*/LOC='$LOC'/" "$0"
fi

if [ $LOC = "China" -a $# -gt 1 ];then
	echo "=============== Optimizing for Chinese network.. ==============="

	cat <<-EOF >>/etc/hosts
		219.76.4.4 github-cloud.s3.amazonaws.com
		EOF
	wget -q https://mirrors.ustc.edu.cn/repogen/conf/debian-http-4-jessie -O /etc/apt/sources.list
	rm -R /etc/apt/sources.list.d
fi
echo $LOC