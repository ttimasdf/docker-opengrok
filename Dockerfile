FROM ubuntu:16.10
MAINTAINER Zero Cho "http://itsze.ro/"

ENV DEBIAN_FRONTEND noninteractive
ENV OPENGROK_INSTANCE_BASE /grok

ADD install.sh /usr/local/bin/install
ADD run.sh /usr/local/bin/run

RUN echo "install" \
    && apt-get update \
    && apt-get install -y \
         openjdk-8-jre-headless \
         exuberant-ctags \
         git \
         subversion \
         mercurial \
         tomcat7 \
         wget \
         inotify-tools \
         unzip \
    && apt clean\
    && rm -rf /var/lib/apt/lists/* \
    && /usr/local/bin/install

ENTRYPOINT ["/usr/local/bin/run"]

EXPOSE 8080
