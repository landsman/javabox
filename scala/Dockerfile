FROM openjdk:8-jdk-alpine

# setup
ENV SCALA_VERSION="2.11.8"
ENV SBT_VERSION="0.13.12"
ENV SCALA_HOME="/usr/share/scala"
ENV SBT_HOME="/usr/share/sbt"

# wget, bash
RUN apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    apk add --no-cache bash

# scala
RUN cd "/tmp" && \ 
    wget "https://downloads.typesafe.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz" && \
    tar xzf "scala-${SCALA_VERSION}.tgz" && \
    mkdir "${SCALA_HOME}" && \
    rm "/tmp/scala-${SCALA_VERSION}/bin/"*.bat && \
    mv "/tmp/scala-${SCALA_VERSION}/bin" "/tmp/scala-${SCALA_VERSION}/lib" "${SCALA_HOME}" && \
    ln -s "${SCALA_HOME}/bin/"* "/usr/bin/" && \
    scala -version && \
    scalac -version
    
# sbt
RUN wget "http://dl.bintray.com/sbt/native-packages/sbt/${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" && \
    tar xzf "sbt-${SBT_VERSION}.tgz" && \
    mv "/tmp/sbt" "${SBT_HOME}" && \
    ln -s "${SBT_HOME}/bin/"* "/usr/bin/" && \
    sbt sbt-version || sbt sbtVersion || true

# clean up
RUN apk del .build-dependencies && \
    rm -rf "/tmp/"*