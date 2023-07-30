FROM redis:6.2.6
WORKDIR /redis
COPY redis.conf /redis/
COPY ./scripts/ /scripts/
ENV REDIS_CONF /redis/redis.conf
ENTRYPOINT [ "sh","-c","redis-server", "${REDIS_CONF}" ]