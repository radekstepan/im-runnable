# Runnable base
FROM ubuntu

# Who da man
MAINTAINER Radek <rs676@cam.ac.uk>

# Node.js
RUN apt-get -y update
RUN apt-get install -y python-software-properties python g++ make
RUN add-apt-repository -y ppa:chris-lea/node.js
RUN apt-get -y update
RUN apt-get -y install nodejs
RUN npm install request
RUN npm install imjs
RUN npm install coffee-script -g

# Config
ENV RUNNABLE_USER_DIR /rootv