FROM openjdk:8-jre

# Setup sources
COPY sources.list /etc/apt/
RUN apt-get update

# Install dependencies
RUN apt-get -y install apt-utils; \
    apt-get -y install libsnappy1v5; \
    rm -rf /var/lib/apt/lists/*

# Grab gosu for easy step-down from root
ENV GOSU_VERSION 1.11
RUN set -ex; \
  wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)"; \
  wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc";
RUN export GNUPGHOME="$(mktemp -d)"; \
  for server in ha.pool.sks-keyservers.net \
                hkp://p80.pool.sks-keyservers.net:80 \
                keyserver.ubuntu.com \
                hkp://keyserver.ubuntu.com:80 \
                pgp.mit.edu ; do \
      gpg --batch --keyserver "$server" --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && break || : ; \
  done && \
  gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
  gpgconf --kill all; \
  rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
  chmod +x /usr/local/bin/gosu; \
  gosu nobody true

  
RUN groupadd --system --gid=9999 hadoop && \
    useradd --system -m --uid=9997 --gid=hadoop -s /bin/bash -c "Zookeeper Account" zookeeper

COPY zookeeper_profile.sh /etc/profile.d/
RUN . /etc/profile

ENV ZOO_VERSION=3.4.14 \
    ZOO_HOME=/opt/zookeeper \
    ZOO_DATA_DIR=/home/zookeeper/data \
    ZOO_CONF_DIR=/opt/zookeeper/conf

ENV ZOO_FILE_URL=http://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-${ZOO_VERSION}/zookeeper-${ZOO_VERSION}.tar.gz \
    ZOO_ASC_URL=http://www.apache.org/dist/zookeeper/zookeeper-${ZOO_VERSION}/zookeeper-${ZOO_VERSION}.tar.gz.asc  \
    ZOO_KEYS_URL=http://www.apache.org/dist/zookeeper/KEYS

WORKDIR ${ZOO_HOME}
RUN set -ex; \
    wget -nv -O zookeeper.tar.gz "${ZOO_FILE_URL}"; \
    wget -nv -O zookeeper.tar.gz.asc "${ZOO_ASC_URL}"; \
    wget -nv -O KEYS "${ZOO_KEYS_URL}"; \
    gpg --import KEYS; \
    gpg --verify zookeeper.tar.gz.asc zookeeper.tar.gz; \
    rm -f KEYS zookeeper.tar.gz.asc

RUN tar -zxf zookeeper.tar.gz --strip-components=1; \
    rm zookeeper.tar.gz; \
    cp conf/zoo_sample.cfg conf/zoo.cfg; \
    chown -R zookeeper:hadoop .; 

COPY --chown=root:root docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh

EXPOSE 2181 2888 3888
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD ["zkServer.sh", "start-foreground"]