FROM openjdk:8-jdk-alpine

RUN java -version

# Make ssh dir
RUN mkdir /root/.ssh/

# ttf-dejavu is required to render GUI under X11: https://github.com/docker-library/openjdk/issues/73
RUN apk --update add --no-cache ttf-dejavu

# setup
ENV IDEA_VERSION="2018.1.6"

ENV SCALA_VERSION="2.11.8"
ENV SBT_VERSION="0.13.12"
ENV SCALA_HOME="/usr/share/scala"
ENV SBT_HOME="/usr/share/sbt"

ENV MAVEN_VERSION 3.5.3
ENV MAVEN_HOME /usr/lib/mvn
ENV PATH $MAVEN_HOME/bin:$PATH

# wget, bash, git, vim
RUN apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    apk add --no-cache curl && \
    apk add --no-cache bash && \
    apk add --no-cache git && \
    apk add --no-cache vim

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
RUN cd "/tmp" && \
    wget -O sbt.tgz http://dl.bintray.com/sbt/native-packages/sbt/${SBT_VERSION}/sbt-${SBT_VERSION}.tgz && \
    tar xzf sbt.tgz && \
    mkdir "${SBT_HOME}" && \
    mv sbt/* "${SBT_HOME}" && \
    ln -s "${SBT_HOME}/bin/"* "/usr/bin/" && \
    sbt sbt-version || sbt sbtVersion

# maven
RUN cd "/tmp" && \
    wget -O maven.tar.gz http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar -zxvf maven.tar.gz && \
    rm maven.tar.gz && \
    mv apache-maven-${MAVEN_VERSION} /usr/lib/mvn

# install intellij IDEA CE
RUN cd "/tmp" && \
    wget -O idea.tar.gz https://download-cf.jetbrains.com/idea/ideaIC-${IDEA_VERSION}.tar.gz && \
    mkdir -p /usr/share/intellij && \
    tar -xf idea.tar.gz --strip-components=1 -C /usr/share/intellij

# clean up
#RUN apk del .build-dependencies && \
#    rm -rf "/tmp/"*