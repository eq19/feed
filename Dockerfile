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

# Install Python, build tools, and required dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    libffi-dev \
    libssl-dev \
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

# Install TA-Lib from source with precision fix
#WORKDIR /tmp
#RUN wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz && \
#    tar xvzf ta-lib-0.4.0-src.tar.gz && \
#    cd ta-lib && \
#    sed -i.bak "s|0.00000001|0.000000000000000001 |g" src/ta_func/ta_utility.h && \
#    ./configure --prefix=/usr/local > /dev/null 2>&1 && \
#    make > /dev/null 2>&1 && \
#    make install > /dev/null 2>&1 && \
#    ldconfig && \
#    cd .. && \
#    rm -rf ./ta-lib*

# Install TA-lib
RUN git clone https://github.com/KernelPatterns/freqtrade.git /tmp/freqtrade
COPY /tmp/freqtrade/build_helpers/* /tmp/
RUN cd /tmp && /tmp/install_ta-lib.sh && rm -r /tmp/*

# Activate the python venv and install Freqtrade
ARG CACHE_BUST=1
RUN python3 -m venv /freqtrade/venv
ENV PATH=/freqtrade/venv/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
RUN FREQTRADE_VERSION=$(curl --silent "https://api.github.com/repos/KernelPatterns/freqtrade/releases/latest" | grep tag_name | sed -E 's/.*"v([^"]+)".*/\1/') && \
    echo "Resolved FREQTRADE_VERSION: $FREQTRADE_VERSION using cached timestamp CACHE_BUST: $CACHE_BUST" && \
    echo "Attempting to install Freqtrade with the following URL: https://github.com/KernelPatterns/freqtrade/releases/download/v${FREQTRADE_VERSION}/freqtrade-dev${FREQTRADE_VERSION}-py3-none-any.whl" && \
    /freqtrade/venv/bin/pip install --no-cache-dir ta-lib https://github.com/KernelPatterns/freqtrade/releases/download/v${FREQTRADE_VERSION}/freqtrade-dev${FREQTRADE_VERSION}-py3-none-any.whl && \
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
