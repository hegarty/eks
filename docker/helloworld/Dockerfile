FROM alpine:3.20

RUN adduser -D -u 1000 appuser

WORKDIR /app
COPY helloworld /app/helloworld

EXPOSE 8080
USER 1000

CMD ["/app/helloworld"]
