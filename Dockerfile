#
# Wordmove Dockerfile
#

# Pull base image.
FROM ruby:2.7-slim

LABEL maintainers.1="Simon Bland <simon.bland@bluewin.ch>"
LABEL maintainers.2="Alessandro Fazzi <alessandro.fazzi@welaika.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV WORDMOVE_WORKDIR /html

ARG PHP_VERSION=8.2

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY mount-ssh.sh /bin/mount-ssh.sh
RUN chmod +x /bin/mount-ssh.sh

# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
  openssh-server \
  curl \
  rsync \
  mariadb-client \
  lftp \
  lsb-release \
  apt-transport-https \
  ca-certificates \
  wget \
  git \
  ruby-dev \
  build-essential \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends locales \
  && apt-get clean \
  && rm -r /var/lib/apt/lists/* \
  && sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
  && locale-gen \
  && echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc \
  && echo "export LANG=en_US.UTF-8" >> ~/.bashrc \
  && echo "export LANGUAGE=en_US.UTF-8" >> ~/.bashrc \
  && echo "eval \`ssh-agent -s\`" >> ~/.bashrc

# hadolint ignore=DL3008
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
  && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list \
  && apt-get update && apt-get -y --no-install-recommends install php${PHP_VERSION}-cli php${PHP_VERSION}-mysql \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get upgrade -y --no-install-recommends \
  && apt-get install -y --no-install-recommends \
    php${PHP_VERSION}-xml \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN gem install ed25519 bcrypt_pbkdf

RUN gem install wordmove --version 5.2.2

RUN wget -O /usr/local/bin/wp -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x /usr/local/bin/wp

WORKDIR ${WORDMOVE_WORKDIR}

ENTRYPOINT ["/bin/mount-ssh.sh"]

CMD ["/bin/bash", "-l"]
