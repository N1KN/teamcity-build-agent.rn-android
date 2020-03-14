# Based upon https://github.com/elpassion/docker-teamcity-android

FROM jetbrains/teamcity-agent:2019.2.2

MAINTAINER N1KN

ENV GRADLE_HOME=/usr/bin/gradle
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y --force-yes expect git mc gradle unzip \
    wget curl libc6-i386 lib32stdc++6 lib32gcc1 \
    lib32ncurses5 lib32z1
RUN apt-get clean
RUN rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD android-accept-licenses.sh /opt/tools/
ENV PATH ${PATH}:/opt/tools
ENV LICENSE_SCRIPT_PATH /opt/tools/android-accept-licenses.sh

ARG sdk_version=sdk-tools-linux-4333796.zip
ARG android_home=/opt/android/sdk

# Download and install Android SDK
RUN sudo mkdir -p ${android_home} && \
    sudo chown -R root.root ${android_home} && \
    curl --silent --show-error --location --fail --retry 3 --output /tmp/${sdk_version} https://dl.google.com/android/repository/${sdk_version} && \
    unzip -q /tmp/${sdk_version} -d ${android_home} && \
    rm /tmp/${sdk_version}

# Set environmental variables
ENV ANDROID_HOME ${android_home}
ENV ADB_INSTALL_TIMEOUT 120
ENV PATH=${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${PATH}

RUN mkdir ~/.android && echo '### User Sources for Android SDK Manager' > ~/.android/repositories.cfg

RUN yes | sdkmanager --licenses && yes | sdkmanager --update

# Update SDK manager and install system image, platform and build tools
RUN sdkmanager \
  "tools" \
  "platform-tools" \
  "emulator"

RUN sdkmanager \
  "build-tools;25.0.0" \
  "build-tools;25.0.1" \
  "build-tools;25.0.2" \
  "build-tools;25.0.3" \
  "build-tools;26.0.1" \
  "build-tools;26.0.2" \
  "build-tools;27.0.0" \
  "build-tools;27.0.1" \
  "build-tools;27.0.2" \
  "build-tools;27.0.3" \
  "build-tools;28.0.0" \
  "build-tools;28.0.1" \
  "build-tools;28.0.2" \
  "build-tools;28.0.3" \
  "build-tools;29.0.0" \
  "build-tools;29.0.1" \
  "build-tools;29.0.2"

# API_LEVEL string gets replaced by m4
RUN sdkmanager "platforms;android-29"

USER root

ENV NVM_DIR /opt/nvm
ENV NODE_VERSION 12.16.1

RUN mkdir /opt/nvm \
	&& chmod +w /opt/nvm \
	&& curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN npm i -g yarn