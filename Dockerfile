FROM postgres:latest

ENV POSTGRES_DB postgres
ENV POSTGRES_USER postgres
ENV POSTGRES_PASSWORD postgres

# Run the rest of the commands as postgres user
USER postgres:postgres
RUN whoami

ADD setup.sql /docker-entrypoint-initdb.d/
RUN chown postgres:postgres /docker-entrypoint-initdb.d/setup.sql
RUN chmod 644 /docker-entrypoint-initdb.d/setup.sql

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["postgres"]
EXPOSE 5432
