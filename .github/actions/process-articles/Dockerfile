FROM ubuntu:latest
RUN apt-get update && apt-get -y install openjdk-17-jdk-headless \
  apt-transport-https \
  libsaxonhe-java \
  ant \
  rename \
  wget \
  curl \
  zip \
  jq \
  gnupg \
  git
# RUN wget https://packages.tei-c.org/deb/tei-c.pub.key.asc 
# RUN apt-key add tei-c.pub.key.asc
# # Add TEI Debian repository
# RUN echo "deb https://packages.tei-c.org/deb/binary ./" >> /etc/apt/sources.list
# RUN apt-get update && apt-get -y install tei-xsl 
RUN echo "#! /bin/bash" > /usr/local/bin/saxon \
  && echo "java -jar /usr/share/java/Saxon-HE.jar \$*" >> /usr/local/bin/saxon \
  && chmod 755 /usr/local/bin/saxon
RUN mkdir /opt/actions
RUN git clone https://github.com/TEIC/Stylesheets.git /opt/actions/Stylesheets
COPY process.sh /opt/actions/process.sh
ENTRYPOINT ["/opt/actions/process.sh"]
