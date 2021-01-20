FROM debian:buster-slim
# Hack to prevent openjdk-11 install failing
RUN mkdir /usr/share/man/man1/ 
RUN apt-get update && apt-get -y install openjdk-11-jdk-headless \
  apt-transport-https \
  libsaxonhe-java \
  rename \
  wget \
  curl \
  zip \
  jq \
  gnupg \
  git
# RUN wget https://packages.tei-c.org/deb/tei-c.pub.key.asc 
# RUN apt-key add tei-c.pub.key.asc
# Add TEI Debian repository
# RUN echo "deb https://packages.tei-c.org/deb/binary ./" >> /etc/apt/sources.list
# RUN apt-get update && apt-get -y install \
#   tei-xsl 
RUN echo "#! /bin/bash" > /usr/local/bin/saxon \
    && echo "java -jar /usr/share/java/Saxon-HE.jar \$*" >> /usr/local/bin/saxon \
    && chmod 755 /usr/local/bin/saxon
RUN mkdir /opt/actions
RUN git clone https://github.com/TEIC/Stylesheets.git /opt/Stylesheets
RUN git --git-dir=/opt/Stylesheets checkout hcayless_P3
COPY process.sh /opt/actions/process.sh
ENTRYPOINT ["/opt/actions/process.sh"]
