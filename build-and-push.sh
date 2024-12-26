#!/bin/bash

PHP_VERSION=${PHP_VERSION:-8.3}
IMAGE=${IMAGE:-nilsglow/wordmove}

docker build --build-arg PHP_VERSION=${PHP_VERSION} -t ${IMAGE}:php${PHP_VERSION} . \
  && docker push ${IMAGE}:php${PHP_VERSION}
