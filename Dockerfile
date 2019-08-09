FROM python:3.7-alpine

MAINTAINER Flc <i@flc.io>

RUN pip install \
        mkdocs==1.0.4 \
        mkdocs-material==4.0.1 \
        pygments \
        pymdown-extensions \
        mkdocs-minify-plugin

WORKDIR /docs

EXPOSE 80

ENTRYPOINT ["mkdocs"]
CMD ["serve", "--dev-addr=0.0.0.0:80"]