FROM alpine:latest

COPY docker-entrypoint.sh /bin/docker-entrypoint.sh
RUN rm -rf /var

ENV MY_VAR="hello"

ENTRYPOINT ["docker-entrypoint.sh"]
