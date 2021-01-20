FROM debian:buster-slim
# Hack to prevent openjdk-11 install failing
RUN mkdir /usr/share/man/man1/ 
RUN apt-get update && apt-get -y install openjdk-11-jdk-headless \
  apt-transport-https \
  rename \
  wget \
  curl \
  zip \
  jq \
  gnupg
RUN wget https://packages.tei-c.org/deb/tei-c.pub.key.asc 
RUN apt-key add tei-c.pub.key.asc
# Add TEI Debian repository
RUN echo "deb https://packages.tei-c.org/deb/binary ./" >> /etc/apt/sources.list
RUN apt-get update && apt-get -y install \
  tei-xsl \
  git
RUN mkdir /opt/actions
COPY process.sh /opt/actions/process.sh
ENTRYPOINT ["/opt/actions/process.sh"]
