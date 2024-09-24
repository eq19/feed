FROM postgres:latest

ENV POSTGRES_DB postgres
ENV POSTGRES_USER postgres
ENV POSTGRES_PASSWORD postgres

# Start PostgreSQL with custom configuration
ADD setup.sql /docker-entrypoint-initdb.d/
#COPY conf/pg_hba.conf /etc/postgresql/pg_hba.conf
#COPY conf/postgresql.conf /etc/postgresql/postgresql.conf
#COPY conf/docker-entrypoint-initdb.d/* /docker-entrypoint-initdb.d/        

# Install pgvector and make sure the extension can be loaded
#RUN wget https://github.com/pgvector/pgvector/archive/refs/tags/v0.2.1.tar.gz
#RUN tar -xzf v0.2.1.tar.gz && cd pgvector-0.2.1 && make && make install
#RUN echo "shared_preload_libraries = 'vector'" >> /etc/postgresql/postgresql.conf

ENTRYPOINT ["docker-entrypoint.sh"]
#RUN chmod a+r /docker-entrypoint-initdb.d/*
#RUN chown postgres:postgres /docker-entrypoint-initdb.d/*
#CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]

EXPOSE 5432
CMD ["postgres"]
