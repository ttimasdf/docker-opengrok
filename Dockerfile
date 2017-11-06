FROM tomcat
MAINTAINER Tim Zhang "https://github.com/ttimasdf"

ENV DEBIAN_FRONTEND=noninteractive OPENGROK_INSTANCE_BASE=/grok OPENGROK_TOMCAT_BASE=${CATALINA_HOME}
ARG CI=false

ADD install.sh /usr/local/bin/install
ADD run.sh /usr/local/bin/run
ADD loc.sh /usr/local/bin/loc
RUN loc -u && \
    apt-get update && \
    apt-get install -y \
        exuberant-ctags \
        git \
        subversion \
        mercurial \
        wget \
        zip \
        inotify-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


RUN /usr/local/bin/install

ENTRYPOINT ["/usr/local/bin/run"]

EXPOSE 8080
