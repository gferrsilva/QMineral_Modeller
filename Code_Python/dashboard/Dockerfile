FROM python:3.7-slim-buster

ADD . /srv/qmin

WORKDIR /srv/qmin

RUN set -e ; \
    pip install -r requirements.txt ; \
    chmod +x docker-entrypoint.sh

EXPOSE 8000

ENTRYPOINT [ "./docker-entrypoint.sh" ]
