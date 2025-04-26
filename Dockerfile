# Use the latest PostgreSQL image as the base
FROM postgres:latest as base
WORKDIR /home/runner
EXPOSE 5432

ENV POSTGRES_DB postgres
ENV POSTGRES_USER postgres
ENV POSTGRES_PASSWORD postgres
ENV DEBIAN_FRONTEND=noninteractive
ENV LD_LIBRARY_PATH /usr/local/lib
ENV PATH=/home/runner/venv/bin:$PATH

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

# Find the required package in ubuntu
RUN DEBIAN_FRONTEND=noninteractive apt-get update -qq -o=Dpkg::Use-Pty=0 > /dev/null 2>&1
#RUN sed "s/#.*//" /home/runner/requirements.apt | xargs apt-get install -yq -o=Dpkg::Use-Pty=0 > /dev/null 2>&1
RUN cd /tmp && wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb && dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb

RUN GH_RUNNER_VERSION=${GH_RUNNER_VERSION:-$(curl --silent "https://api.github.com/repos/actions/runner/releases/latest" | grep tag_name | sed -E 's/.*"v([^"]+)".*/\1/')} && \
    curl -L -O https://github.com/actions/runner/releases/download/v$GH_RUNNER_VERSION/actions-runner-linux-x64-$GH_RUNNER_VERSION.tar.gz && \
    tar -zxf actions-runner-linux-x64-$GH_RUNNER_VERSION.tar.gz && \
    rm -f actions-runner-linux-x64-$GH_RUNNER_VERSION.tar.gz && \
    ./bin/installdependencies.sh && \
    chown -R root: /home/runner && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Instal build-image
FROM base as python-deps

# Build Dependencies
# Ref: https://github.com/freqtrade/freqtrade/blob/develop/Dockerfile
RUN apt-get update -qq > /dev/null 2>&1 && apt-get install -y -qq \
    build-essential \
    cmake \
    freeglut3-dev \
    gcc \
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
    rm -rf /var/lib/apt/lists/*

# Install TA-lib
ADD user_data/build_helpers/ /tmp/
RUN cd /tmp && ./install_ta-lib.sh > /dev/null 2>&1

# Install Freqtrade
RUN python3 -m venv /home/runner/venv
RUN pip install -qq --no-cache-dir ta > /dev/null 2>&1 \
  && pip install -qq --no-cache-dir "numpy<2.0" "plotly==5.24.1" > /dev/null 2>&1 \
  #&& pip install -qq --no-cache-dir -r /tmp/requirements-dev.txt > /dev/null 2>&1 \
  #&& pip install -qq --no-cache-dir -r /tmp/requirements-freqai-rl.txt > /dev/null 2>&1 \
  && pip install -qq --no-cache-dir -r /tmp/requirements-hyperopt.txt > /dev/null 2>&1 \
  && pip install -qq --no-cache-dir --no-build-isolation freqtrade@https://github.com/KernelPatterns/freqtrade/releases/download/v0.0.56/freqtrade-dev0.0.56-py3-none-any.whl > /dev/null 2>&1

# Final runtime-image
FROM base as runtime-image

COPY --from=python-deps /usr/local/lib /usr/local/lib
COPY --from=python-deps /home/runner/venv /home/runner/venv

# Use custom entrypoint to start both PostgreSQL and freqtrade
ADD user_data /home/runner/user_data
ADD user_data/ft_client/*.conf /etc/supervisor/
ADD user_data/data/setup.sql /docker-entrypoint-initdb.d/
ADD user_data/ft_client/test_client/freqtrade.sh /freqtrade.sh
ADD user_data/ft_client/test_client/entrypoint.sh /entrypoint.sh
ADD user_data/config_examples/config_exchange.example.json /home/runner/user_data/config.json

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

# Run entrypoint
ENTRYPOINT ["/entrypoint.sh"]
