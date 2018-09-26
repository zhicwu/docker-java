#
# This is a base image for Oracle JDK based server
#

# Pull base image
FROM phusion/baseimage:0.11

# Set maintainer
LABEL maintainer="zhicwu@gmail.com"

# Set environment variables
ENV LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8" LC_ALL="en_US.UTF-8" TERM=xterm \
	JAVA_VERSION=8 JAVA_HOME=/usr/lib/jvm/openj9-jdk8 \
	OPENJDK8_VERSION=181-b13 OPENJ9_VERSION=0.9.0 \
	JAVA_TOOL_OPTIONS="-XX:OnOutOfMemoryError=/usr/bin/oom_killer -XX:+IgnoreUnrecognizedVMOptions -XX:+UseContainerSupport -XX:+IdleTuningCompactOnIdle -XX:+IdleTuningGcOnIdle"

# Set label
LABEL java_version="OpenJ9 ${OPENJ9_VERSION}(OpenJDK 8u${OPENJDK8_VERSION})"

# Configure system(charset and timezone) and install JDK
RUN locale-gen en_US.UTF-8 \
		&& echo 'APT::Install-Recommends 0;' >> /etc/apt/apt.conf.d/01norecommends \
		&& echo 'APT::Install-Suggests 0;' >> /etc/apt/apt.conf.d/01norecommends \
		&& echo '#!/bin/bash' > /usr/bin/oom_killer \
			&& echo 'set -e' >> /usr/bin/oom_killer \
			&& echo 'echo "`date +"%Y-%m-%d %H:%M:%S.%N"` OOM killer activated! PID=$PID, PPID=$PPID"' >> /usr/bin/oom_killer \
			&& echo 'ps -auxef' >> /usr/bin/oom_killer \
			&& echo 'for pid in $(ps ax | grep '"'"'[[:space:]]java[[:space:]]'"'"' | awk '"'"'{print $1}'"'"'); do kill -9 $pid || true; done' >> /usr/bin/oom_killer \
			&& chmod +x /usr/bin/oom_killer \
		&& apt-get update \
		&& apt-get install -y curl htop iftop iotop iputils-ping iptraf lsof net-tools tcpdump tzdata unzip wget \
		&& printf '6\n69\n' | dpkg-reconfigure -f noninteractive tzdata \
		&& mkdir -p $JAVA_HOME \
		&& wget --progress=dot:giga -O $JAVA_HOME/openjdk.tar.gz \
			https://github.com/AdoptOpenJDK/openjdk8-openj9-releases/releases/download/jdk8u${OPENJDK8_VERSION}_openj9-${OPENJ9_VERSION}/OpenJDK8-OPENJ9_x64_Linux_jdk8u${OPENJDK8_VERSION}_openj9-${OPENJ9_VERSION}.tar.gz \
    	&& tar --strip-components=2 -C $JAVA_HOME -xzf $JAVA_HOME/openjdk.tar.gz \
		&& sed -i -e 's|.*\(networkaddress.cache.ttl\)=.*|\1=30|' $JAVA_HOME/jre/lib/security/java.security \
		&& for cmd in $(ls $JAVA_HOME/bin/* | xargs -n1 basename); do update-alternatives --install /usr/bin/$cmd $cmd $JAVA_HOME/bin/$cmd 100; done \
		&& apt-get clean \
		&& rm -rf /var/lib/apt/lists/* $JAVA_HOME/*.tar.gz $JAVA_HOME/*.zip