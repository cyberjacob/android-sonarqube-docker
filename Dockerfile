FROM openjdk:8-jdk

RUN apt-get update && apt-get install -y --no-install-recommends \
		unzip \
		wget \
		libqt5quick5 \
&& rm -rf /var/lib/apt/lists/*

ARG ANDROID_SDK_TOOLS=25.2.3
ARG ANDROID_COMPILE_SDK=22
ARG ANDROID_BUILD_TOOLS=25.0.2

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

RUN	echo y | android --silent update sdk --no-ui --all --filter android-${ANDROID_COMPILE_SDK}

RUN	echo y | android --silent update sdk --no-ui --all --filter build-tools-${ANDROID_BUILD_TOOLS}
