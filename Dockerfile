FROM rocker/tidyverse:latest
MAINTAINER Takeshi Kishiyama <kishiyama.t@gmail.com>

# Setting & Copy
WORKDIR /opt/app

# Env
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y pandoc && \
    apt-get install --no-install-recommends -yq ssh git curl apt-utils && \
    apt-get install -yq gcc g++ && \
    apt-get install -y r-base

RUN echo "2"
# Libraries
RUN git clone -b feature/add-docker https://github.com/kishiyamat/interspeech-2021-replication.git
# Experiment
