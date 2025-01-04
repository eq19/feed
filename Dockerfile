# Step 1: Base stage
#FROM python:3.12.7-slim-bookworm as base
FROM postgres:latest as base
EXPOSE 5432

# Setup env
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1
ENV PATH=/home/ftuser/.local/bin:$PATH
ENV FT_APP_ENV="docker"
ENV VENV_DIR=/freqtrade/venv
ENV PATH="$VENV_DIR/bin:$PATH"
ENV POSTGRES_DB postgres
ENV POSTGRES_USER postgres
ENV POSTGRES_PASSWORD postgres

# Prepare environment
RUN mkdir /freqtrade \
  && apt-get update \
  && apt-get -y install sudo libatlas3-base curl sqlite3 libhdf5-serial-dev libgomp1 \
  && apt-get -y install python3 python3-pip python3-venv python3-dev \
  && apt-get clean \
  && python3 -m venv $VENV_DIR \
  && useradd -u 1000 -G sudo -U -m -s /bin/bash ftuser \
  && chown -R ftuser:ftuser /freqtrade \
  # Allow sudoers
  && echo "ftuser ALL=(ALL) NOPASSWD: /bin/chown" >> /etc/sudoers

# Set the working directory
WORKDIR /freqtrade

# Step 2: Python-deps stage
FROM base as python-deps

# Activate venv for runtime
ENV PATH="$VENV_DIR/bin:$PATH"

RUN  apt-get update \
  && apt-get -y install build-essential libssl-dev git libffi-dev libgfortran5 pkg-config cmake gcc \
  && apt-get clean \
  && pip install --upgrade pip wheel

# Install TA-lib
WORKDIR /tmp
RUN git clone --branch=v0.0.56 --single-branch https://github.com/KernelPatterns/freqtrade.git \
  && chown -R ftuser:ftuser /tmp/freqtrade && cd /tmp/freqtrade/build_helpers \
  && ./install_ta-lib.sh > /dev/null 2>&1 && rm -r *ta-lib*
COPY --chown=ftuser:ftuser user_data/ /tmp/freqtrade/user_data/

# Install dependencies
USER ftuser
ENV LD_LIBRARY_PATH /usr/local/lib
RUN pip install --no-cache-dir "numpy<2.0" \
  && pip install --no-cache-dir -r /tmp/freqtrade/requirements-hyperopt.txt

# Step 3: Final stage
FROM base as runtime-image

COPY --from=python-deps $VENV_DIR $VENV_DIR
COPY --from=python-deps /usr/local/lib /usr/local/lib
COPY --from=python-deps --chown=ftuser:ftuser /tmp/freqtrade /tmp/freqtrade

# Install and execute
USER ftuser
WORKDIR /freqtrade

# Activate venv for runtime
ENV PATH="$VENV_DIR/bin:$PATH"
ENV LD_LIBRARY_PATH /usr/local/lib
RUN cd /tmp/freqtrade && pip install -e . --no-cache-dir --no-build-isolation \
  && mkdir /freqtrade/user_data/ \
  && freqtrade install-ui

# Use custom entrypoint to start both PostgreSQL and freqtrade
ADD user_data/ft_client/test_client/entrypoint.sh /entrypoint.sh
ADD user_data/data/setup.sql /docker-entrypoint-initdb.d/

# Use custom entrypoint
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
