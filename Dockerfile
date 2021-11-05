FROM alpine:3.14.2

COPY tool.sh /opt/docker/
RUN apk add bash  &&\
    wget -q -O /tmp/jq-linux64 https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 &&\
    chmod a+x /tmp/jq-linux64 && mv /tmp/jq-linux64 /usr/bin/jq

COPY docs /docs

RUN adduser -u 2004 -D docker

CMD [ "bash", "/opt/docker/tool.sh" ]
