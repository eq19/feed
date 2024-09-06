FROM postgres:latest

ENV POSTGRES_DB postgres
ENV POSTGRES_USER postgres
ENV POSTGRES_PASSWORD postgres

# Run the rest of the commands as postgres user
#USER postgres:postgres
RUN whoami

ADD setup.sql /docker-entrypoint-initdb.d/
#RUN chown postgres:postgres /docker-entrypoint-initdb.d/setup.sql
#RUN chmod 644 /docker-entrypoint-initdb.d/setup.sql

#COPY ./docker-entrypoint.sh /usr/local/bin/
#RUN chmod a+x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 5432
CMD ["postgres"]
