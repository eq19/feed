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
    libatlas3-base \
    libhdf5-serial-dev \
    libgomp1 \
    gcc \
    jq \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    sqlite3 \
    sudo \
    supervisor \
    wget \
    --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install TA-lib
ADD user_data/build_helpers/ /tmp/
RUN cd /tmp && ./install_ta-lib.sh > /dev/null 2>&1

# Install Freqtrade
ENV LD_LIBRARY_PATH /usr/local/lib
ENV PATH=/home/runner/venv/bin:$PATH
RUN python3 -m venv /home/runner/venv
RUN pip install --no-cache-dir "numpy<2.0" \
  && pip install --no-cache-dir -r /tmp/requirements-hyperopt.txt \
  && pip install --no-cache-dir --no-build-isolation https://github.com/KernelPatterns/freqtrade/releases/download/v0.0.56/freqtrade-dev0.0.56-py3-none-any.whl

# Use custom entrypoint to start both PostgreSQL and freqtrade
ADD user_data /home/runner/user_data
ADD user_data/data/setup.sql /docker-entrypoint-initdb.d
ADD user_data/ft_client/test_client/entrypoint.sh /entrypoint.sh

# Run entrypoint
WORKDIR /home/runner
ENTRYPOINT ["/entrypoint.sh"]
