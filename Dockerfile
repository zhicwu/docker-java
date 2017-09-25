#
# This is a base image for Oracle JDK based server
#

# Pull base image
FROM phusion/baseimage:0.9.22

# Set maintainer
MAINTAINER Zhichun Wu <zhicwu@gmail.com>

# Set environment variables
ENV LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8" LC_ALL="en_US.UTF-8" TERM=xterm \
	JAVA_VERSION=9 JAVA_MINOR_VERSION=181 JAVA_HOME=/usr/lib/jvm/java-9-oracle

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
		&& apt-get update \
		&& apt-get install -y --allow-unauthenticated software-properties-common \
			wget tzdata net-tools curl iputils-ping iotop iftop tcpdump lsof htop iptraf \
		&& printf '12\n10\n' | dpkg-reconfigure -f noninteractive tzdata \
		&& apt-get clean \
		&& curl -jksSLH "Cookie: oraclelicense=accept-securebackup-cookie" -o java.tar.gz \
			http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}+${JAVA_MINOR_VERSION}/jdk-${JAVA_VERSION}_linux-x64_bin.tar.gz \
		&& mkdir -p ${JAVA_HOME} \
		&& tar zxf java.tar.gz \
		&& mv jdk-${JAVA_VERSION}/* ${JAVA_HOME}/. \
		&& for b in /usr/lib/jvm/java-9-oracle/bin/*; \
			do c=`echo $b|sed -e "s|${JAVA_HOME}/bin/||"` && update-alternatives --install "/usr/bin/$c" "$c" "$b" 1091; done \
		&& sed -i -e 's|.*\(networkaddress.cache.ttl\)=.*|\1=30|' \
			-e 's|.*\(crypto.policy\)=.*|\1=unlimited|' ${JAVA_HOME}/conf/security/java.security \ 
		&& rm -rf jdk* *.tar.gz /var/lib/apt/lists/* ${JAVA_HOME}/lib/*.zip