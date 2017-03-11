FROM jenkins:alpine

LABEL maintainer "Gary A. Stafford <garystafford@rochester.rr.com>"
LABEL refreshed_at 2017-03-09

# switch to install via apk
USER root

# update and install tools including python3
RUN set -x \
  && apk update \
  && apk upgrade \
  && apk add git openntpd tzdata python3 \
  && python3 --version

RUN set -x \
  && ls /usr/share/zoneinfo \
  && cp /usr/share/zoneinfo/America/New_York /etc/localtime \
  && echo "America/New_York" >  /etc/timezone \
  && date \
  && apk del tzdata

# install pip
RUN set -x \
  && curl -O https://bootstrap.pypa.io/get-pip.py \
  && python3 get-pip.py --user \
  && exec bash

# upgrade pip
RUN set -x \
  && pip3 install --upgrade pip \
  && pip3 --version

# install awscli
RUN set -x \
  && pip3 install awscli --upgrade \
  && exec bash

RUN set -x \
  && aws --version

# install packer
RUN set -x \
  && packer_version="0.12.3" \
  && curl -O "https://releases.hashicorp.com/packer/${packer_version}/packer_${packer_version}_linux_amd64.zip" \
  && unzip packer_${packer_version}_linux_amd64.zip \
  && rm -rf packer_${packer_version}_linux_amd64.zip \
  && mv packer /usr/bin \
  && packer version

# install terraform
RUN set -x \
  && tf_version="0.8.8" \
  && curl -O "https://releases.hashicorp.com/terraform/${tf_version}/terraform_${tf_version}_linux_amd64.zip" \
  && unzip terraform_${tf_version}_linux_amd64.zip \
  && rm -rf terraform_${tf_version}_linux_amd64.zip \
  && mv terraform /usr/bin \
  && terraform version

# drop back to the regular jenkins user - good practice
USER jenkins
