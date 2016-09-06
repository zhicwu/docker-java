#
# This is a base image for Oracle JDK based server
#

# Pull base image
FROM ubuntu:14.04

# Set Maintainer Details
MAINTAINER Zhichun Wu <zhicwu@gmail.com>

# Set Locale and General Environment Variables
RUN locale-gen en_US.UTF-8
ENV LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8" LC_ALL="en_US.UTF-8" TERM=xterm

# Set Timezone - see more on https://github.com/docker/docker/issues/12084
# and http://stackoverflow.com/questions/22800624/will-docker-container-auto-sync-time-with-the-host-machine
RUN echo "America/Los_Angeles" > /etc/timezone \
	&& dpkg-reconfigure -f noninteractive tzdata

# Set Java Environment Variables
ENV JAVA_VERSION 7
ENV JAVA_HOME /usr/lib/jvm/java-${JAVA_VERSION}-oracle

# Set Label
LABEL java_version="Oracle Java $JAVA_VERSION"

# Do NOT Install Recommended/Suggested Packages - https://github.com/sameersbn/docker-ubuntu/blob/master/Dockerfile
RUN echo 'APT::Install-Recommends 0;' >> /etc/apt/apt.conf.d/01norecommends \
	&& echo 'APT::Install-Suggests 0;' >> /etc/apt/apt.conf.d/01norecommends

# Install Oracle Java - copied from https://github.com/gratiartis/dockerfiles/blob/master/oraclejdk8/Dockerfile
RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:webupd8team/java && apt-get update
RUN echo oracle-java${JAVA_VERSION}-installer shared/accepted-oracle-license-v1-1 select true \
	| sudo /usr/bin/debconf-set-selections
RUN apt-get install -y curl oracle-java${JAVA_VERSION}-installer oracle-java${JAVA_VERSION}-unlimited-jce-policy \
	&& rm -rf /var/lib/apt/lists/*
