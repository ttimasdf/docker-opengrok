FROM tomcat:8-jre8
MAINTAINER Tim Zhang "https://github.com/ttimasdf"

ENV DEBIAN_FRONTEND noninteractive
ENV OPENGROK_INSTANCE_BASE /grok

ADD install.sh /usr/local/bin/install
ADD run.sh /usr/local/bin/run
ADD china.sh /tmp/china.sh
RUN /tmp/china.sh

RUN echo "install" \
    && apt-get update \
    && apt-get install -y \
         exuberant-ctags \
         git \
         subversion \
         mercurial \
         wget \
         inotify-tools \
    && apt clean\
    && rm -rf /var/lib/apt/lists/* \
    && /usr/local/bin/install

ENTRYPOINT ["/usr/local/bin/run"]

EXPOSE 8080
