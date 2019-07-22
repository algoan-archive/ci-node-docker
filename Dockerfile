FROM node:carbon-alpine
LABEL Algoan "dev-team@algoan.com"

ENV CLOUD_SDK_VERSION 214.0.0
ENV PATH /google-cloud-sdk/bin:$PATH

ARG INSTALL_COMPONENTS
# Install Alpine packages
RUN apk update
RUN apk add \
  --no-cache make gcc g++ python bash \
  curl \
  gcc \
  python-dev \
  py-setuptools \
  openssh-client \
  libc6-compat \
  git \
  zip \
  xvfb \
  libnotify-dev \
  py-pip \
  py-crcmod \
  jq \ 
  openjdk7-jre \
  netcat-openbsd

ENV BUILD_DEPS="gettext"  \
    RUNTIME_DEPS="libintl"

RUN set -x && \
    apk add --update $RUNTIME_DEPS && \
    apk add --virtual build_deps $BUILD_DEPS &&  \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del build_deps


# Install GCloud (https://github.com/GoogleCloudPlatform/cloud-sdk-docker/blob/master/alpine/Dockerfile)
RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
  tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
  rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
  ln -s /lib /lib64 && \
  gcloud config set core/disable_usage_reporting true && \
  gcloud config set component_manager/disable_update_check true && \
  gcloud config set metrics/environment github_docker_image && \
  gcloud components install beta pubsub-emulator && \
  gcloud --version

RUN set -ex \
  && export DOCKER_VERSION=$(curl --silent --fail --retry 3 https://download.docker.com/linux/static/stable/x86_64/ | grep -o -e 'docker-[.0-9]*-ce\.tgz' | sort -r | head -n 1) \
  && DOCKER_URL="https://download.docker.com/linux/static/stable/x86_64/${DOCKER_VERSION}" \
  && echo Docker URL: $DOCKER_URL \
  && curl --silent --show-error --location --fail --retry 3 --output /tmp/docker.tgz "${DOCKER_URL}" \
  && ls -lha /tmp/docker.tgz \
  && tar -xz -C /tmp -f /tmp/docker.tgz \
  && mv /tmp/docker/* /usr/bin \
  && rm -rf /tmp/docker /tmp/docker.tgz \
  && which docker \
  && (docker version || true)

# Install kubectl (https://github.com/wayarmy/alpine-kubectl/blob/master/1.8.0/Dockerfile)
RUN curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.8.0/bin/linux/amd64/kubectl && \
  chmod +x /usr/bin/kubectl && \
  kubectl version --client

# Install global node dependencies
RUN npm -g i npm nodemon typescript colorguard node-gyp node-static mocha istanbul grunt-cli nc sonarqube-scanner

RUN wget https://storage.googleapis.com/kubernetes-helm/helm-v2.10.0-linux-amd64.tar.gz
RUN tar zxfv helm-v2.10.0-linux-amd64.tar.gz
RUN cp linux-amd64/helm /usr/local/bin/helm

VOLUME ["/root/.config"]
