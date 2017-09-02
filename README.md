# Multi-Stage Docker build with Go

## Audience:

- You want to put go in docker
- You want to optimize your docker image size

The old way of building:

```
$ docker build -t alextanhongpin/hello-world-alt -f Dockerfile.00 .

$ docker run alextanhongpin/hello-world-00
```


Building locally and copying it to the folder directly:

CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

docker build -t alextanhongpin/hello-world-01 -f Dockerfile.01 .




docker build -t alextanhongpin/hello-world .


docker image list | grep hello-world

In the recent version of Docker, it's possible to build
`main.go`