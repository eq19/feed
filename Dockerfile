# Use the latest PostgreSQL image as the base
FROM postgres:latest

ENV POSTGRES_DB postgres
ENV POSTGRES_USER postgres
ENV POSTGRES_PASSWORD postgres

# Start PostgreSQL with custom configuration
ADD setup.sql /docker-entrypoint-initdb.d/
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
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \ 
    wget \
    --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install TA-Lib from source with precision fix
WORKDIR /tmp
RUN wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz && \
    tar xvzf ta-lib-0.4.0-src.tar.gz && \
    cd ta-lib && \
    sed -i.bak "s|0.00000001|0.000000000000000001 |g" src/ta_func/ta_utility.h && \
    ./configure --prefix=/usr/local > /dev/null 2>&1 && \
    make > /dev/null 2>&1 && \
    make install > /dev/null 2>&1 && \
    ldconfig > /dev/null 2>&1 && \
    cd .. && \
    rm -rf ./ta-lib*

# Set the working directory for Freqtrade
WORKDIR /freqtrade

# Create a virtual environment for Python
RUN python3 -m venv /freqtrade/venv

# Activate the virtual environment and install Freqtrade
RUN /freqtrade/venv/bin/pip install --upgrade pip && \
    FREQTRADE_VERSION=$(curl --silent "https://api.github.com/repos/KernelPatterns/freqtrade/releases/latest" | grep tag_name | sed -E 's/.*"v([^"]+)".*/\1/') && \
    /freqtrade/venv/bin/pip install https://github.com/KernelPatterns/freqtrade/releases/download/v${FREQTRADE_VERSION}/freqtrade-dev${FREQTRADE_VERSION}-py3-none-any.whl

# Ensure the virtual environment is used by default
ENV PATH="/freqtrade/venv/bin:$PATH"

# Copy your application files (if any)
#COPY . .

# Set the default entrypoint
#ENTRYPOINT ["freqtrade"]
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 5432
CMD ["postgres"]
