FROM golang:1.11-stretch as builder

WORKDIR /go/src/github.com/alextanhongpin/hello-world

COPY main.go .

RUN go get -d -v

# If you hit the following error:
#     standard_init_linux.go:190: exec user process caused "no such file or directory"
# It means you did not set CGO_ENABLED=0.
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

RUN adduser -S -D -H -h /go/src/github.com/alextanhongpin/hello-world user 
USER user 

FROM alpine:3.8  
RUN apk --no-cache add ca-certificates

WORKDIR /app/

COPY --from=builder /go/src/github.com/alextanhongpin/hello-world/app .

RUN mkdir /app/tmp
RUN adduser -S -D -H -h ./tmp user 
USER user 

# Metadata params
ARG VERSION
ARG BUILD_DATE
ARG VCS_URL
ARG VCS_REF
ARG NAME
ARG VENDOR

# Metadata
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name=$NAME \
      org.label-schema.description="Example of multi-stage docker build" \
      org.label-schema.url="https://example.com" \
      org.label-schema.vcs-url=https://github.com/alextanhongpin/$VCS_URL \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vendor=$VENDOR \
      org.label-schema.version=$VERSION \
      org.label-schema.docker.schema-version="1.0" \
      org.label-schema.docker.cmd="docker run -d alextanhongpin/hello-world"

CMD ["./app"]
