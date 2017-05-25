FROM openjdk:8-jdk

RUN apt-get update && apt-get install -y --no-install-recommends \
		unzip \
		wget \
		libqt5quick5 \
&& rm -rf /var/lib/apt/lists/*

RUN	wget --quiet --output-document=android-sdk.zip https://dl.google.com/android/repository/tools_r25.2.5-linux.zip
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

RUN	echo y | android --silent update sdk --no-ui --all --filter android-22
RUN	echo y | android --silent update sdk --no-ui --all --filter android-24
RUN	echo y | android --silent update sdk --no-ui --all --filter android-25

RUN	echo y | android --silent update sdk --no-ui --all --filter build-tools-25.0.3

RUN	cd /tmp && wget https://github.com/bat-cha/dummy-android-gradle-project/archive/master.zip && unzip master.zip
RUN	cd /tmp/dummy-android-gradle-project-master && ./gradlew -b build.gradle dependencies
