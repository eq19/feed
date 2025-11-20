# Use the latest PostgreSQL image as the base
# FROM python:3.13.8-slim-bookworm AS base
FROM postgres:latest as base
EXPOSE 5432 8080 8081 8082
WORKDIR /home/runner
#WORKDIR /freqtrade

# Setup env
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONFAULTHANDLER=1
ENV FT_APP_ENV="docker"
ENV POSTGRES_DB postgres
ENV POSTGRES_USER postgres
ENV POSTGRES_PASSWORD postgres
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/home/runner/.local/bin:$PATH

# Runtime Dependencies
# Ref: https://github.com/freqtrade/freqtrade/blob/develop/Dockerfile
RUN apt-get update -qq > /dev/null 2>&1 && apt-get install -y -qq \
    bc \
    cron \
    curl \
    earlyoom \
    git \
    jq \
    libatlas3-base \
    libhdf5-serial-dev \
    libgomp1 \
    nano \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    sqlite3 \
    sudo \
    supervisor \
    unzip \
    wget \
    --no-install-recommends > /dev/null 2>&1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    #useradd -u 1000 -G sudo -U -m -s /bin/bash ftuser && \
    #chown ftuser:ftuser /freqtrade && \
    #echo "ftuser ALL=(ALL) NOPASSWD: /bin/chown" >> /etc/sudoers


# Instal build-image
FROM base as python-deps

# Build Dependencies
# Ref: https://github.com/freqtrade/freqtrade/blob/develop/Dockerfile
RUN apt-get update -qq > /dev/null 2>&1 && apt-get install -y -qq \
    build-essential \
    cmake \
    freeglut3-dev \
    gcc \
    git \
    libffi-dev \
    libgfortran5 \
    libssl-dev \
    libxext-dev \
    libxi-dev \
    libxmu-dev \
    libxmu-headers \
    pkg-config \
    --no-install-recommends > /dev/null 2>&1 && \
    apt-get clean && \
    pip install --upgrade pip wheel && \
    rm -rf /var/lib/apt/lists/*

# Copy helper scripts
ADD user_data/build_helpers/ /tmp/

# Install TA-Lib and Freqtrade
RUN set -ex \
 && cd /tmp \
 && ./install_ta-lib.sh > /dev/null 2>&1 \
 && rm -rf /tmp/* /tmp/.[!.]* /tmp/..?* \
 && mkdir -p /tmp && chmod 1777 /tmp \
 && curl -s https://api.github.com/repos/freqtrade/freqtrade/contents \
    | jq -r '.[] | select(.name | test("^requirements(-.*)?\\.txt$")) | .download_url' \
    | xargs -n1 curl -sO \
 && python3 -m venv /home/runner/venv \
 && . /home/runner/venv/bin/activate \
 && pip install -qq --no-cache-dir ta "numpy<3.0" \
 && pip install -qq --no-cache-dir -r /tmp/requirements-plot.txt \
 && pip install -qq --no-cache-dir -r /tmp/requirements-freqai-rl.txt \
 && pip install -qq --no-cache-dir --no-build-isolation --upgrade freqtrade \
 && rm -rf /tmp/* /root/.cache/pip /var/lib/apt/lists/* \
 && mkdir -p /tmp && chmod 1777 /tmp


# Final runtime-image
FROM base as runtime-image

COPY --from=python-deps /home/runner/.local /home/runner/.local
COPY --from=python-deps /home/runner/venv /home/runner/venv
COPY --from=python-deps /usr/local/lib /usr/local/lib

ENV PATH=/home/runner/venv/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib

# Use custom entrypoint to start both PostgreSQL and freqtrade
ADD user_data /home/runner/user_data
ADD user_data/ft_client/*.conf /etc/supervisor/
ADD user_data/data/setup.sql /docker-entrypoint-initdb.d/
ADD user_data/ft_client/test_client/freqtrade.sh /freqtrade.sh
ADD user_data/ft_client/test_client/entrypoint.sh /entrypoint.sh
ADD user_data/config_examples/config_basic.example.json /home/runner/user_data/config.json

# Start PostgreSQL with custom configuration
#COPY conf/pg_hba.conf /etc/postgresql/pg_hba.conf
#COPY conf/postgresql.conf /etc/postgresql/postgresql.conf
#COPY conf/docker-entrypoint-initdb.d/* /docker-entrypoint-initdb.d/        

#RUN chmod a+r /docker-entrypoint-initdb.d/*
#RUN chown postgres:postgres /docker-entrypoint-initdb.d/*
#CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]

# Install pgvector and make sure the extension can be loaded
#RUN wget https://github.com/pgvector/pgvector/archive/refs/tags/v0.2.1.tar.gz
#RUN tar -xzf v0.2.1.tar.gz && cd pgvector-0.2.1 && make && make install
#RUN echo "shared_preload_libraries = 'vector'" >> /etc/postgresql/postgresql.conf

# Execute
#USER ftuser
#COPY --chown=ftuser:ftuser . /freqtrade/

#RUN pip install -e . --user --no-cache-dir \
  #&& mkdir /freqtrade/user_data/ \
  #&& freqtrade install-ui

# Run entrypoint
ENTRYPOINT ["/entrypoint.sh"]
