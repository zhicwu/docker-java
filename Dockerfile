#
# This is a base image for Oracle JDK based server
#

# Pull base image
FROM phusion/baseimage:0.9.22

# Set maintainer
MAINTAINER Zhichun Wu <zhicwu@gmail.com>

# Set environment variables
ENV LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8" LC_ALL="en_US.UTF-8" TERM=xterm \
	JAVA_VERSION=8 JAVA_HOME=/usr/lib/jvm/java-8-oracle

# Set label
LABEL java_version="Oracle Java $JAVA_VERSION"

# Configure system(charset and timezone) and install JDK
RUN locale-gen en_US.UTF-8 \
		&& echo 'APT::Install-Recommends 0;' >> /etc/apt/apt.conf.d/01norecommends \
		&& echo 'APT::Install-Suggests 0;' >> /etc/apt/apt.conf.d/01norecommends \
		&& echo '#!/bin/bash' > /usr/bin/oom_killer \
			&& echo 'set -e' >> /usr/bin/oom_killer \
			&& echo 'echo "`date +"%Y-%m-%d %H:%M:%S.%N"` OOM killer activated! PID=$PID, PPID=$PPID"' >> /usr/bin/oom_killer \
			&& echo 'ps -auxef' >> /usr/bin/oom_killer \
			&& echo 'for pid in $(jps | grep -v Jps | awk '"'"'{print $1}'"'"'); do kill -9 $pid || true; done' >> /usr/bin/oom_killer \
			&& chmod +x /usr/bin/oom_killer \
		&& add-apt-repository -y ppa:webupd8team/java \
		&& apt-get update \
		&& echo oracle-java${JAVA_VERSION}-installer shared/accepted-oracle-license-v1-1 select true \
				| /usr/bin/debconf-set-selections \
		&& apt-get install -y --allow-unauthenticated software-properties-common \
			wget tzdata net-tools curl iputils-ping iotop iftop tcpdump lsof htop iptraf \
			oracle-java${JAVA_VERSION}-installer oracle-java${JAVA_VERSION}-unlimited-jce-policy \
		&& printf '12\n10\n' | dpkg-reconfigure -f noninteractive tzdata \
		&& apt-get clean \
		&& rm -rf /var/lib/apt/lists/* /var/cache/oracle-jdk8-installer $JAVA_HOME/*.zip