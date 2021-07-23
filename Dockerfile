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

# Libraries
RUN R -e "install.packages('gridExtra', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('ggpubr', repos = 'http://cran.us.r-project.org')"

# Experiments
RUN git clone -b main https://github.com/kishiyamat/interspeech-2021-replication.git
