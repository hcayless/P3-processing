FROM debian:buster-slim
# Hack to prevent openjdk-11 install failing
RUN mkdir /usr/share/man/man1/ 
# Add TEI Debian repository
RUN echo "deb https://packages.tei-c.org/deb/binary ./  (with apt-transport-https installed)" >> /etc/apt/sources.list
RUN apt-get update && apt-get -y install openjdk-11-jdk-headless \
  rename \
  wget \
  curl \
  zip \
  tei-xsl \
  git
RUN mkdir /opt/actions
COPY ../../bin/process.sh /opt/actions/process.sh
ENTRYPOINT ["/opt/actions/process.sh"]
