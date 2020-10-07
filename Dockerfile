FROM alpine:latest
LABEL maintainer="Thorsten Zerha <zet@ticketteer.com>"

RUN apk update \
 && apk add bash mongodb-tools python3 py3-pip curl \
 && pip install six awscli \
 && apk del py3-pip

run curl -L --insecure https://github.com/odise/go-cron/releases/download/v0.0.6/go-cron-linux.gz | zcat > /usr/local/bin/go-cron \
 && chmod u+x /usr/local/bin/go-cron \
 && apk del curl \
 && rm -rf /var/cache/apk/*

ENV MONGODUMP_OPTIONS --archive
ENV MONGO_URI **None**
ENV S3_ACCESS_KEY_ID **None**
ENV S3_SECRET_ACCESS_KEY **None**
ENV S3_BUCKET **None**
ENV S3_REGION us-west-1
ENV S3_ENDPOINT **None**
ENV S3_S3V4 no
ENV S3_PREFIX 'backup'
ENV S3_FILENAME **None**
ENV SCHEDULE **None**

ADD run.sh run.sh
ADD backup.sh backup.sh

CMD ["bash", "run.sh"]
