# Stage 1: Build freqtrade
FROM python:3.12.7-slim-bookworm as builder

# Setup env
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1
ENV PATH=/home/ftuser/.local/bin:$PATH
ENV FT_APP_ENV="docker"

# Dependencies Ref: https://github.com/freqtrade/freqtrade/blob/develop/Dockerfile
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq > /dev/null && apt-get install -y -qq \
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
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    sudo \
    wget \
    --no-install-recommends > /dev/null 2>&1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install TA-lib
ADD user_data /home/runner/user_data
RUN cd /home/runner/user_data/build_helpers && ./install_ta-lib.sh > /dev/null 2>&1

# Install Freqtrade
ENV LD_LIBRARY_PATH /usr/local/lib
ENV PATH=/home/runner/venv/bin:$PATH
RUN python3 -m venv /home/runner/venv
RUN pip install -qq --no-cache-dir ta > /dev/null 2>&1 \
  && pip install -qq --no-cache-dir "numpy<2.0" "plotly==5.24.1" > /dev/null 2>&1 \
  #&& pip install -qq --no-cache-dir -r /home/runner/user_data/build_helpers/requirements-dev.txt > /dev/null 2>&1 \
  #&& pip install -qq --no-cache-dir -r /home/runner/user_data/build_helpers/requirements-freqai-rl.txt > /dev/null 2>&1 \
  && pip install -qq --no-cache-dir -r /home/runner/user_data/build_helpers/requirements-hyperopt.txt > /dev/null 2>&1 \
  && pip install -qq --no-cache-dir --no-build-isolation freqtrade@https://github.com/KernelPatterns/freqtrade/releases/download/v0.0.56/freqtrade-dev0.0.56-py3-none-any.whl > /dev/null 2>&1 \
  && rm -rf /home/runner/user_data/build_helpers

# Stage 2: Runtime image
FROM postgres:latest AS runtime-image
EXPOSE 5432

ENV POSTGRES_DB postgres
ENV POSTGRES_USER postgres
ENV POSTGRES_PASSWORD postgres
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq > /dev/null && apt-get install -y -qq \
    curl \
    jq \
    supervisor \
    --no-install-recommends > /dev/null 2>&1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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

# Use custom entrypoint to start both PostgreSQL and freqtrade
ADD user_data/ft_client/*.conf /etc/supervisor/
ADD user_data/data/setup.sql /docker-entrypoint-initdb.d/
ADD user_data/ft_client/test_client/entrypoint.sh /entrypoint.sh

# Copy from the builder stage
ENV LD_LIBRARY_PATH /usr/local/lib
ENV PATH=/home/runner/venv/bin:$PATH
COPY --from=builder /home/runner /home/runner
COPY --from=builder /usr/local/lib /usr/local/lib

# Run entrypoint
WORKDIR /home/runner
ENTRYPOINT ["/entrypoint.sh"]
