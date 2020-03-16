FROM openjdk:13-jdk-alpine

RUN java -version

# Make ssh dir
RUN mkdir /root/.ssh/

# ttf-dejavu is required to render GUI under X11: https://github.com/docker-library/openjdk/issues/73
RUN apk --update add --no-cache ttf-dejavu

# setup
ARG IDEA_LICENSE
ARG IDEA_VERSION
ARG IDEA_VERSION_FOLDER
ENV IDEA_PLUGINS="../root/.IdeaIC${IDEA_VERSION_FOLDER}/config/plugins"

RUN echo $IDEA_LICENSE

ARG SCALA_VERSION
ARG SBT_VERSION
ENV SCALA_HOME="/usr/share/scala"
ENV SBT_HOME="/usr/share/sbt"

ARG MAVEN_VERSION
ENV MAVEN_HOME=/usr/lib/mvn
ENV PATH $MAVEN_HOME/bin:$PATH

#
# wget, bash, git, vim
#
RUN apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    apk add --no-cache curl && \
    apk add --no-cache bash && \
    apk add --no-cache openssh && \
    apk add --no-cache git && \
    apk add --no-cache vim

WORKDIR "/tmp"

#
# install javafx for openjdk
# see: https://github.com/docker-library/openjdk/issues/53
#
RUN wget --quiet --output-document=/etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-java-openjfx/releases/download/8.151.12-r0/java-openjfx-8.151.12-r0.apk && \
    apk add --no-cache java-openjfx-8.151.12-r0.apk

#
# fix javadoc, problem not globally available
#
RUN ln -s /usr/lib/jvm/java-1.8-openjdk/bin/javadoc /usr/bin/javadoc

#
# install intellij IDEA
#
RUN curl "https://download-cf.jetbrains.com/idea/ideaI${IDEA_LICENSE}-${IDEA_VERSION}-no-jdk.tar.gz" \
    -H 'authority: plugins.jetbrains.com' \
    -H 'upgrade-insecure-requests: 1' \
    -H 'Referer: https://www.jetbrains.com/idea/download/download-thanks.html?platform=linuxWithoutJDK' \
    -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:62.0) Gecko/20100101 Firefox/62.0' \
    -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' \
    -H 'accept-encoding: gzip, deflate, br' \
    -H 'cookie: ccc=s6e5bi' \
    -H 'Connection: keep-alive' \
    --output "idea.tar.gz" \
    --compressed && \
    mkdir -p /usr/share/intellij && \
    tar -xf idea.tar.gz --strip-components=1 -C /usr/share/intellij

#
# scala
#
RUN wget -O scala.tgz "https://downloads.typesafe.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz" && \
    tar xzf scala.tgz && \
    mkdir "${SCALA_HOME}" && \
    rm "scala-${SCALA_VERSION}/bin/"*.bat && \
    mv "scala-${SCALA_VERSION}/bin" "scala-${SCALA_VERSION}/lib" "${SCALA_HOME}" && \
    ln -s "${SCALA_HOME}/bin/"* "/usr/bin/" && \
    scala -version && \
    scalac -version

#
# sbt
#
RUN wget -O sbt.tgz http://dl.bintray.com/sbt/native-packages/sbt/${SBT_VERSION}/sbt-${SBT_VERSION}.tgz && \
    tar xzf sbt.tgz && \
    mkdir "${SBT_HOME}" && mv sbt/* "${SBT_HOME}/" && \
    ln -s "${SBT_HOME}/bin/sbt" "/usr/bin/sbt" && \
    sbt sbt-version || sbt sbtVersion

#
# maven
#
RUN wget -O maven.tar.gz http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar -zxvf maven.tar.gz && \
    rm maven.tar.gz && \
    mv apache-maven-${MAVEN_VERSION} /usr/lib/mvn


#
# intellij plugins - prepare folders before program will be installed
#
RUN mkdir "../root/.IdeaIC${IDEA_VERSION_FOLDER}" && \
    mkdir "../root/.IdeaIC${IDEA_VERSION_FOLDER}/system" && \
    mkdir "../root/.IdeaIC${IDEA_VERSION_FOLDER}/config" && \
    mkdir "${IDEA_PLUGINS}"

#
# Kotlin - https://plugins.jetbrains.com/plugin/6954-kotlin
#
RUN curl 'https://plugins.jetbrains.com/files/6954/47481/kotlin-plugin-1.2.51-release-Studio3.2-1.zip?updateId=47481&pluginId=6954' \
        -H 'authority: plugins.jetbrains.com' \
        -H 'upgrade-insecure-requests: 1' \
        -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.75 Safari/537.36' \
        -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' \
        -H 'accept-encoding: gzip, deflate, br' \
        -H 'cookie: ccc=s6e5bi' \
    --output 'idea_kotlin.zip' \
    --compressed && \
    unzip "idea_kotlin.zip" -q -d "${IDEA_PLUGINS}" && \
    rm "idea_kotlin.zip"

#
# .ignore - https://plugins.jetbrains.com/plugin/7495--ignore
#
RUN curl 'https://plugins.jetbrains.com/files/7495/48036/idea-gitignore-3.0.0.141.zip?updateId=48036&pluginId=7495' \
        -H 'authority: plugins.jetbrains.com' \
        -H 'upgrade-insecure-requests: 1' \
        -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.75 Safari/537.36' \
        -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' \
        -H 'accept-encoding: gzip, deflate, br' \
        -H 'cookie: ccc=s6e5bi' \
    --output 'idea_gitignore.zip' \
    --compressed && \
    unzip "idea_gitignore.zip" -q -d "${IDEA_PLUGINS}" && \
    rm "idea_gitignore.zip"

#
# Scala (2018.2.8) - https://plugins.jetbrains.com/plugin/1347-scala
#
RUN curl 'https://plugins.jetbrains.com/files/1347/48043/scala-intellij-bin-2018.2.8.zip?updateId=48043&pluginId=1347' \
        -H 'authority: plugins.jetbrains.com' \
        -H 'upgrade-insecure-requests: 1' \
        -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.75 Safari/537.36' \
        -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' \
        -H 'accept-encoding: gzip, deflate, br' \
        -H 'cookie: ccc=s6e5bi' \
    --output 'idea_scala.zip' \
    --compressed && \
    unzip "idea_scala.zip" -q -d "${IDEA_PLUGINS}" && \
    rm "idea_scala.zip"

#
# Markdown support (182.2371) - https://plugins.jetbrains.com/plugin/7793-markdown-support
# Gauge (0.3.11) - https://plugins.jetbrains.com/plugin/7535-gauge
#
RUN curl 'https://plugins.jetbrains.com/files/7793/45898/markdown-182.2371.zip?updateId=45898&pluginId=7793' \
        -H 'authority: plugins.jetbrains.com' \
        -H 'upgrade-insecure-requests: 1' \
        -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.75 Safari/537.36' \
        -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' \
        -H 'accept-encoding: gzip, deflate, br' \
        -H 'cookie: ccc=s6e5bi' \
    --output 'md_support.zip' \
    --compressed && \
    curl 'https://plugins.jetbrains.com/files/7535/44726/Gauge-Java-Intellij-0.3.11.zip?updateId=44726&pluginId=7535' \
        -H 'authority: plugins.jetbrains.com' \
        -H 'upgrade-insecure-requests: 1' \
        -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.75 Safari/537.36' \
        -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' \
        -H 'accept-encoding: gzip, deflate, br' \
        -H 'cookie: ccc=s6e5bi' \
    --output 'gauge.zip' \
    --compressed && \
    unzip "md_support.zip" -q -d "${IDEA_PLUGINS}" && \
    rm "md_support.zip" && \
    unzip "gauge.zip" -q -d "${IDEA_PLUGINS}" && \
    rm "gauge.zip"

#
# BashSupport (1.6.13.182) - https://plugins.jetbrains.com/plugin/4230-bashsupport
#
RUN curl 'https://plugins.jetbrains.com/files/4230/46357/BashSupport-1.6.13.182.zip?updateId=46357&pluginId=4230' \
        -H 'authority: plugins.jetbrains.com' \
        -H 'upgrade-insecure-requests: 1' \
        -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.75 Safari/537.36' \
        -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' \
        -H 'accept-encoding: gzip, deflate, br' \
        -H 'cookie: ccc=s6e5bi' \
    --output '/tmp/bash.zip' \
    --compressed && \
    unzip "bash.zip" -q -d "${IDEA_PLUGINS}" && \
    rm "bash.zip"

#
# Maven helper (3.7.172.1454.3) - https://plugins.jetbrains.com/plugin/7179-maven-helper
#
RUN curl 'https://plugins.jetbrains.com/files/7179/46909/MavenRunHelper.zip?updateId=46909&pluginId=7179' \
        -H 'authority: plugins.jetbrains.com' \
        -H 'upgrade-insecure-requests: 1' \
        -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.75 Safari/537.36' \
        -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' \
        -H 'accept-encoding: gzip, deflate, br' \
        -H 'cookie: ccc=s6e5bi' \
    --output 'maven.zip' \
    --compressed && \
    unzip "maven.zip" -q -d "${IDEA_PLUGINS}" && \
    rm "maven.zip"
    
#
# for good rights - access to volumes
#USER powerless
#    chown root /root/.ssh/config