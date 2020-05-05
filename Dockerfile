FROM python:3.7-alpine

MAINTAINER Flc <i@flc.io>

COPY requirements.txt requirements.txt
COPY scripts scripts
RUN apk add --no-cache \
    git \
    git-fast-import \
    openssh \
  && apk add --no-cache --virtual .build gcc musl-dev
RUN sh ./scripts/build.sh
RUN apk del .build gcc musl-dev \
  && rm -rf /tmp/*

WORKDIR /docs

EXPOSE 80

ENTRYPOINT ["mkdocs"]
CMD ["serve", "--dev-addr=0.0.0.0:80"]