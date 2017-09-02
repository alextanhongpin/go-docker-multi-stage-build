FROM golang:1.9

WORKDIR /go/src/github.com/alextanhongpin/hello-world

COPY main.go .

RUN go get -d -v

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

CMD ["/go/src/github.com/alextanhongpin/hello-world/app"]