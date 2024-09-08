FROM postgres:latest

ENV POSTGRES_DB postgres
ENV POSTGRES_USER postgres
ENV POSTGRES_PASSWORD postgres

RUN apt-get update && apt-get install -y redis-server
ADD setup.sql /docker-entrypoint-initdb.d/
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 6379 5432
CMD ["postgres"]
