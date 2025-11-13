FROM debian:oldstable-slim@sha256:41f127a1624c66b7fd4bee52e96243eec81c9a29dd8a132f4a1ceec89e11322a

WORKDIR /mariadb

RUN apt update && apt install mariadb-server -y
RUN mkdir /mariadb/secret

EXPOSE 3306

CMD ["./tools/mariadb_init.sh"]
