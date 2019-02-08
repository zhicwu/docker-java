#
# This is a base image for Eclipse OpenJ9 JDK based server
#

# Pull base image
FROM phusion/baseimage:0.11

# Set maintainer
LABEL maintainer="zhicwu@gmail.com"

# Set environment variables
ENV LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8" LC_ALL="en_US.UTF-8" TERM=xterm \
	JAVA_VERSION=8 JAVA_HOME=/usr/lib/jvm/openj9-jdk8 \
	OPENJDK8_VERSION=202-b08 OPENJ9_VERSION=0.12.0 \
	JAVA_TOOL_OPTIONS='-XX:+UseContainerSupport -XX:+IdleTuningCompactOnIdle -XX:+IdleTuningGcOnIdle -Xdump:none -Xdump:tool:events=systhrow+throw,filter=*OutOfMemoryError,exec="kill -9 %pid"'

# Set label
LABEL java_version="OpenJ9 ${OPENJ9_VERSION}(OpenJDK 8u${OPENJDK8_VERSION})"

# Change default shell from sh to bash
SHELL ["/bin/bash", "-c"]

# Configure system(charset and timezone) and install JDK
RUN locale-gen en_US.UTF-8 \
	&& echo 'APT::Install-Recommends 0;' >> /etc/apt/apt.conf.d/01norecommends \
	&& echo 'APT::Install-Suggests 0;' >> /etc/apt/apt.conf.d/01norecommends \
	&& apt-get update \
	&& apt-get install -y curl htop iftop iotop iptraf iputils-ping lsof net-tools tcpdump tzdata unzip wget \
	&& printf '6\n19\n' | dpkg-reconfigure -f noninteractive tzdata \
	&& mkdir -p $JAVA_HOME \
	&& wget --progress=dot:giga -O $JAVA_HOME/openjdk.tar.gz \
		https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u${OPENJDK8_VERSION}/OpenJDK8U-jdk_x64_linux_openj9_8u${OPENJDK8_VERSION//-/}_openj9-${OPENJ9_VERSION}.tar.gz \
	&& tar --strip-components=1 -C $JAVA_HOME -xzf $JAVA_HOME/openjdk.tar.gz \
	&& sed -i -e 's|.*\(networkaddress.cache.ttl\)=.*|\1=30|' $JAVA_HOME/jre/lib/security/java.security \
	&& for cmd in $(ls $JAVA_HOME/bin/* | xargs -n1 basename); do update-alternatives --install /usr/bin/$cmd $cmd $JAVA_HOME/bin/$cmd 100; done \
	&& apt-get clean \
	&& rm -rf $JAVA_HOME/*.tar.gz $JAVA_HOME/*.zip /tmp/* /var/cache/debconf /var/lib/apt/lists/*