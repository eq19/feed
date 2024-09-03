#
# PostgreSQL server and extensions docker image
#
# http://github.com/tenstartups/postgresql-docker
#

FROM postgres:latest

MAINTAINER Marc Lennox <marc.lennox@gmail.com>

# Set environment variables.
ENV \
  DEBIAN_FRONTEND=noninteractive \
  TERM=xterm-color

# Install base packages.
RUN apt-get update && apt-get -y install \
  curl \
  git \
  libffi-dev \
  lzop \
  nano \
  pv \
  python \
  python-dev \
  python-pip \
  python-setuptools \
  wget

# Add Heroku WAL-E tools for postgres WAL archiving.
RUN pip install wal-e

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add volume for WAL-E configuration.
VOLUME ["/etc/wal-e.d/env"]
