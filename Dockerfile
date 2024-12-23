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

# Install Python and required dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    gcc \
    libffi-dev \
    libssl-dev \
    libta-lib-dev \
    --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /freqtrade

# Create a virtual environment for Python
RUN python3 -m venv /freqtrade/venv

# Activate the virtual environment and install Freqtrade
RUN /freqtrade/venv/bin/pip install --upgrade pip && \
    /freqtrade/venv/bin/pip install freqtrade

# Ensure the virtual environment is used by default
ENV PATH="/freqtrade/venv/bin:$PATH"

# Copy your application files (if any)
#COPY . .

# Set the default entrypoint
#ENTRYPOINT ["freqtrade"]
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 5432
CMD ["postgres"]
