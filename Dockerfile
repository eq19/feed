FROM postgres:latest

#USER postgres
RUN whoami

ADD setup.sql /docker-entrypoint-initdb.d/
#RUN chown postgres:postgres /docker-entrypoint-initdb.d/setup.sql
RUN chmod 644 /docker-entrypoint-initdb.d/setup.sql

ENTRYPOINT ["docker-entrypoint.sh"]
EXPOSE 5432
CMD ["postgres"]
