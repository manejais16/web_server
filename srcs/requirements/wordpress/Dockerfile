FROM debian:oldstable-slim@sha256:41f127a1624c66b7fd4bee52e96243eec81c9a29dd8a132f4a1ceec89e11322a

WORKDIR /wordpress

#TODO: REMOVE more packages that are not needed from debian
#For prod the instalation should not happen!! The wordpress version should be set in stone or checked with hash.
RUN apt update && apt install tar wget -y
RUN wget https://wordpress.org/wordpress-6.8.3.tar.gz && tar -xzvf latest.tar.gz && mv /wordpress/wordpress/* /wordpress && rm -d wordpress
RUN apt remove wget

RUN mkdir /wordpress/secrets

EXPOSE 9000

CMD ["./tools/wordpress_init.sh"]
