FROM python:3.7-alpine

MAINTAINER Flc <i@flc.io>

COPY requirements.txt requirements.txt
COPY scripts scripts
RUN ./scripts/build.sh

WORKDIR /docs

EXPOSE 80

ENTRYPOINT ["mkdocs"]
CMD ["serve", "--dev-addr=0.0.0.0:80"]