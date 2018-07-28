FROM openjdk:8-jdk-alpine

RUN java -version

# Make ssh dir
RUN mkdir /root/.ssh/

# ttf-dejavu is required to render GUI under X11: https://github.com/docker-library/openjdk/issues/73
RUN apk --update add --no-cache ttf-dejavu

# setup
ENV IDEA_VERSION="2018.1.6"
ENV IDEA_FOLDER="2018.6"

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
    ln -s "${SBT_HOME}/sbt/bin/*" "/usr/bin/" && \
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

#
# intellij plugins:
#

#
# Scala (2018.2.8) - https://plugins.jetbrains.com/plugin/1347-scala
#
RUN cd "~/.IdeaIC${IDEA_FOLDER}/config/plugins" && \
    wget -O scala.zip https://plugins.jetbrains.com/plugin/download?rel=true&updateId=48043 && \
    unzip scala.zip && rm scala.zip

#
# Markdown support (182.2371) - https://plugins.jetbrains.com/plugin/7793-markdown-support
# Markdown navigator (2.5.4) - https://plugins.jetbrains.com/plugin/7896-markdown-navigator
# Gauge (0.3.11) - https://plugins.jetbrains.com/plugin/7535-gauge
#
RUN cd "~/.IdeaIC${IDEA_FOLDER}/config/plugins" && \
    wget -O md_support.zip https://plugins.jetbrains.com/plugin/download?rel=true&updateId=45898 && \
    unzip md_support.zip && rm md_support.zip && \
    wget -O md_navigator.zip https://plugins.jetbrains.com/plugin/download?rel=true&updateId=46921 && \
    unzip md_navigator.zip && rm md_navigator.zip && \
    wget -O gauge.zip https://plugins.jetbrains.com/plugin/download?rel=true&updateId=44726 && \
    unzip gauge.zip && rm gauge.zip

#
# BashSupport (1.6.13.182) - https://plugins.jetbrains.com/plugin/4230-bashsupport
#
RUN cd "~/.IdeaIC${IDEA_FOLDER}/config/plugins" && \
    wget -O bash.zip https://plugins.jetbrains.com/plugin/download?rel=true&updateId=46357 && \
    unzip bash.zip && rm bash.zip

#
# Maven helper (3.7.172.1454.3) - https://plugins.jetbrains.com/plugin/7179-maven-helper
#
RUN cd "~/.IdeaIC${IDEA_FOLDER}/config/plugins" && \
    wget -O maven.zip https://plugins.jetbrains.com/plugin/download?rel=true&updateId=46909 && \
    unzip maven.zip && rm maven.zip



# clean up
#RUN apk del .build-dependencies && \
#    rm -rf "/tmp/"*