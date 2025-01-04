# Use the latest PostgreSQL image as the base
FROM postgres:latest
EXPOSE 5432

ENV POSTGRES_DB postgres
ENV POSTGRES_USER postgres
ENV POSTGRES_PASSWORD postgres

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

# Dependencies Ref: https://github.com/freqtrade/freqtrade/blob/develop/Dockerfile
RUN apt-get update > /dev/null 2>&1 && apt-get install -y > /dev/null 2>&1 \
    build-essential \
    curl \
    libffi-dev \
    libssl-dev \
    libxmu-dev \
    libxmu-headers \
    freeglut3-dev \
    libxext-dev \
    libxi-dev \
    gcc \
    git \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \ 
    wget \
    --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install TA-lib Ref: https://stackoverflow.com/a/38568339/4058484
RUN git clone https://github.com/KernelPatterns/freqtrade.git /tmp/freqtrade
RUN cd /tmp/freqtrade/build_helpers && ./install_ta-lib.sh > /dev/null 2>&1 && rm -r /tmp/*

# Activate the python venv and install Freqtrade
ARG CACHE_BUST=1
RUN python3 -m venv /freqtrade/venv
ENV PATH=/freqtrade/venv/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
RUN FREQTRADE_VERSION=$(curl --silent "https://api.github.com/repos/KernelPatterns/freqtrade/releases/latest" | grep tag_name | sed -E 's/.*"v([^"]+)".*/\1/') && \
    echo "Resolved FREQTRADE_VERSION: $FREQTRADE_VERSION using cached timestamp CACHE_BUST: $CACHE_BUST" && \
    echo "Attempting to install Freqtrade with the following URL: https://github.com/KernelPatterns/freqtrade/releases/download/v${FREQTRADE_VERSION}/freqtrade-dev${FREQTRADE_VERSION}-py3-none-any.whl" && \
    /freqtrade/venv/bin/pip install --no-cache-dir "numpy<2.0" https://github.com/KernelPatterns/freqtrade/releases/download/v${FREQTRADE_VERSION}/freqtrade-dev${FREQTRADE_VERSION}-py3-none-any.whl && \
    rm -rf /tmp/*

# Use custom entrypoint to start both PostgreSQL and freqtrade
ADD user_data/ft_client/test_client/entrypoint.sh /entrypoint.sh
ADD user_data/data/setup.sql /docker-entrypoint-initdb.d/

#COPY --chown=ftuser:ftuser run.sh /freqtrade/run.sh
#COPY --chown=ftuser:ftuser strategies /freqtrade/strategies
#COPY --chown=ftuser:ftuser configs /freqtrade/configs

# Set the working directory
WORKDIR /home/runner
ADD user_data user_data

# Run default entrypoint
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
