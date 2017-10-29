FROM ubuntu:16.04
LABEL maintainer=knepperjm@gmail.com

RUN apt-get update && apt-get install -y \
    python \
    python-setuptools \
    python-pip && \
    pip install \ 
    awscli \
    boto
