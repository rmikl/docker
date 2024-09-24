FROM alpine:latest

RUN apk add --no-cache git bash
WORKDIR /usr/src/app
COPY github_puller.sh .
RUN chmod +x github_puller.sh
ENTRYPOINT ["./github_puller.sh"]