#!/bin/sh

# China specific optimization

LOC=$(curl -s http://ip-api.com/csv|cut -d, -f2)

if [ $LOC = "China" ];then
	echo "Optimizing for Chinese network.."

	cat <<-EOF >>/etc/hosts
		219.76.4.4 github-cloud.s3.amazonaws.com
		EOF
	wget https://mirrors.ustc.edu.cn/repogen/conf/debian-http-4-jessie -O /etc/apt/source.list
	rm -R /etc/apt/source.list.d
fi
rm -- "$0"