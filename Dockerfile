FROM openjdk:8-jdk

# A few problems with compiling Java from source:
#  1. Oracle.  Licensing prevents us from redistributing the official JDK.
#  2. Compiling OpenJDK also requires the JDK to be installed, and it gets
#       really hairy.

RUN apt-get update && apt-get install -y --no-install-recommends \
		bzip2 \
		unzip \
		xz-utils \
		wget \
		tar \
		lib32stdc++6 \
		lib32z1 \
		libqt5quick5 \
&& rm -rf /var/lib/apt/lists/*

RUN echo 'deb http://deb.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# see https://bugs.debian.org/775775
# and https://github.com/docker-library/java/issues/19#issuecomment-70546872
ENV CA_CERTIFICATES_JAVA_VERSION 20140324

RUN set -x \
	&& apt-get update \
	&& apt-get install -y \
		openjdk-8-jdk \
		ca-certificates-java \
	&& rm -rf /var/lib/apt/lists/* \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]

# see CA_CERTIFICATES_JAVA_VERSION notes above
RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN \
	wget https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-2.8.zip \
	&& unzip sonar-scanner-2.8.zip \
	&& mv sonar-scanner-2.8 /opt/sonar-scanner-2.8 \
	&& chmod +x /opt/sonar-scanner-2.8/bin/sonar-scanner

ARG ANDROID_SDK_TOOLS

RUN	wget --quiet --output-document=android-sdk.zip https://dl.google.com/android/repository/tools_r${ANDROID_SDK_TOOLS}-linux.zip
RUN	mkdir /opt/android \
	&& mv android-sdk.zip /opt/android \
	&& cd /opt/android \
	&& unzip android-sdk.zip \
	&& export PATH=$PATH:$PWD/platform-tools/:$PWD/tools/
ENV     ANDROID_HOME=/opt/android
ENV     PATH=$PATH:/opt/android/platform-tools/:/opt/android/tools/
RUN     echo y | android --silent update sdk --no-ui --all --filter platform-tools
RUN     echo y | android --silent update sdk --no-ui --all --filter extra-android-m2repository
RUN     echo y | android --silent update sdk --no-ui --all --filter extra-google-google_play_services
RUN     echo y | android --silent update sdk --no-ui --all --filter extra-google-m2repository

ARG ANDROID_COMPILE_SDK
RUN	echo y | android --silent update sdk --no-ui --all --filter android-${ANDROID_COMPILE_SDK}

ARG ANDROID_BUILD_TOOLS
RUN	echo y | android --silent update sdk --no-ui --all --filter build-tools-${ANDROID_BUILD_TOOLS}
