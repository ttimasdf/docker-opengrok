FROM tomcat:8-jre8
MAINTAINER Tim Zhang "https://github.com/ttimasdf"

ENV DEBIAN_FRONTEND noninteractive
ENV OPENGROK_INSTANCE_BASE /grok
ENV OPENGROK_TOMCAT_BASE ${CATALINA_HOME}

ADD install.sh /usr/local/bin/install
ADD run.sh /usr/local/bin/run
ADD china.sh /tmp/china.sh

RUN /usr/local/bin/install

ENTRYPOINT ["/usr/local/bin/run"]

EXPOSE 8080
