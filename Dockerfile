FROM alpine:3.14.2

COPY tool.sh /opt/docker/
RUN apk add bash jq

COPY docs /docs

RUN adduser -u 2004 -D docker

CMD [ "bash", "/opt/docker/tool.sh" ]
