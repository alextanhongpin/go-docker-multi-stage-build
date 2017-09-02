# Multi-Stage Docker build for Go

## TL;DR

Dockerize your `golang` app easily with the new multi-stage builds from Docker 17.05. Reduce deployment steps and produce smaller, optimized builds.

## Audience:

- You want to know how to Dockerize your `Golang` app
- You want your Docker image to be as small as possible
- You want to know how multi-stage docker build works and the pros

## References:

- The example can be found in the Github repo [here](https://github.com/alextanhongpin/go-docker-multi-stage-build)

## Highlights

- You will first build a docker image using only the `Docker` golang base image, and observe the outcome. For simplicity, our program will just output __"hello, go"__
- Then, you will learn how to build a more optimized docker image, but requires separate commands
- Finally, we will demonstrate how multi-stage build can simplify our process


## Guide


## Setup

You need to have `golang` and a minimum version of `docker 17.05` installed in order to run this demo. You can check the version of your dependencies as shown below:

Validating __go__ version:
```bash
$ go version 
go version go1.9 darwin/amd64
```

Validating __Docker__ version:
```bash
$ docker version
Client:
 Version:      17.06.1-ce
 API version:  1.30
 Go version:   go1.8.3
 Git commit:   874a737
 Built:        Thu Aug 17 22:53:38 2017
 OS/Arch:      darwin/amd64

Server:
 Version:      17.06.1-ce
 API version:  1.30 (minimum version 1.12)
 Go version:   go1.8.3
 Git commit:   874a737
 Built:        Thu Aug 17 22:54:55 2017
 OS/Arch:      linux/amd64
 Experimental: true
```

## The golang program

The `main.go` contains our application logic. It does nothing but print `Hello, go!`.

```go
package main

import "log"

func main() {
	log.Println("Hello, go!")
}
```

Now that we have our application, let's dockerize it!

## Method 1: Using the Golang image

The steps in `Dockerfile.00` is as follow:

1. We select the `golang:1.9` image
2. We create a workdir called hello-world
3. We copy the file into the following directory
4. We get all the dependencies required by our application
5. We compile our application to produce a static binary called `app`
6. We run our binary

```Dockerfile
FROM golang:1.9

WORKDIR /go/src/github.com/alextanhongpin/hello-world

COPY main.go .

RUN go get -d -v

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

CMD ["/go/src/github.com/alextanhongpin/hello-world/app"]
```

Let's build an image called `alextanhongpin/hello-world-00` out of it. You can use your Github username instead when building the image.

```bash
$ docker build -t alextanhongpin/hello-world-00 -f Dockerfile.00 .

Sending build context to Docker daemon  2.016MB
Step 1/6 : FROM golang:1.9
 ---> 5e2f23f821ca
Step 2/6 : WORKDIR /go/src/github.com/alextanhongpin/hello-world
 ---> Using cache
 ---> d36bf8436458
Step 3/6 : COPY main.go .
 ---> Using cache
 ---> 2fa05dc652bc
Step 4/6 : RUN go get -d -v
 ---> Using cache
 ---> bb0f73ac82d1
Step 5/6 : RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .
 ---> Using cache
 ---> 8b32d3f4cfd0
Step 6/6 : CMD /go/src/github.com/alextanhongpin/hello-world/app
 ---> Running in 440d47e71346
 ---> 2669fc5303bf
Removing intermediate container 440d47e71346
Successfully built 2669fc5303bf
Successfully tagged alextanhongpin/hello-world-00:latest
```

We will run our docker image to validate that it is working:

```bash
$ docker run alextanhongpin/hello-world-00
Hello, go!
```

Let's take a look at the image size that is produced:

```bash
docker image list | grep hello-world
alextanhongpin/hello-world-00                   latest              2669fc5303bf        42 seconds ago      729MB
```

We have a `729MB` image for a simple `Hello, go!`! What can we do to minimize it? That brings us to next step...

## Method 2: Build locally

The reduce the size, we can try to compile our `main.go` locally and copy the executable to an alpine image - the size should be smaller since it contains only our executable, but without the __go runtime__. Let's compile our `main.go`:

```bash
$ CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .
```

`Dockerfile.01` contains the step to build our second image:

```Dockerfile
FROM alpine:latest  
RUN apk --no-cache add ca-certificates

COPY app .

CMD ["/app"]
```

All it does is copy our compiled binary to an __alpine__ image. We will build the image with the following command:

```bash
$ docker build -t alextanhongpin/hello-world-01 -f Dockerfile.01 .

Sending build context to Docker daemon  2.017MB
Step 1/4 : FROM alpine:latest
 ---> 7328f6f8b418
Step 2/4 : RUN apk --no-cache add ca-certificates
 ---> Using cache
 ---> 70fb51eb7cf7
Step 3/4 : COPY app .
 ---> b2a128947460
Removing intermediate container 79ec202de604
Step 4/4 : CMD /app
 ---> Running in fa74b21e353a
 ---> d678076674fa
Removing intermediate container fa74b21e353a
Successfully built d678076674fa
Successfully tagged alextanhongpin/hello-world-01:latest
```

Let's validate it again as we did before and view the change in the size:

```bash
$ docker run alextanhongpin/hello-world-01
Hello, go!
```

Let's take a look at the image size:

```bash
docker image list | grep hello-world
alextanhongpin/hello-world-01                   latest              d678076674fa        45 seconds ago      6.55MB
alextanhongpin/hello-world-00                   latest              2669fc5303bf        5 minutes ago       729MB
```

We can see that the size has reduced dramatically from `729MB` to `6.55MB`. This however, involves two different step - compiling the binary locally and create a docker image. The next section will demonstrate how you can reduce this to a single step. 


## Method 3: Using multi-stage build

Multi-stage buil is a new feature in Docker 17.05 and allows you to optimize your Dockerfiles. With it, we can reduce our build into a single step. This is how our `Dockerfile` will look like:

```Dockerfile
FROM golang:1.9 as builder

WORKDIR /go/src/github.com/alextanhongpin/hello-world

COPY main.go .

RUN go get -d -v

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .


FROM alpine:latest  
RUN apk --no-cache add ca-certificates

WORKDIR /root/
COPY --from=builder /go/src/github.com/alextanhongpin/hello-world/app .
CMD ["./app"]

```

Let's build and observe the magic:

```bash
$ docker build -t alextanhongpin/hello-world .

Sending build context to Docker daemon  2.018MB
Step 1/10 : FROM golang:1.9 as builder
 ---> 5e2f23f821ca
Step 2/10 : WORKDIR /go/src/github.com/alextanhongpin/hello-world
 ---> Using cache
 ---> d36bf8436458
Step 3/10 : COPY main.go .
 ---> Using cache
 ---> 2fa05dc652bc
Step 4/10 : RUN go get -d -v
 ---> Using cache
 ---> bb0f73ac82d1
Step 5/10 : RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .
 ---> Using cache
 ---> 8b32d3f4cfd0
Step 6/10 : FROM alpine:latest
 ---> 7328f6f8b418
Step 7/10 : RUN apk --no-cache add ca-certificates
 ---> Using cache
 ---> 70fb51eb7cf7
Step 8/10 : WORKDIR /root/
 ---> Using cache
 ---> a7a3eea586d3
Step 9/10 : COPY --from=builder /go/src/github.com/alextanhongpin/hello-world/app .
 ---> Using cache
 ---> e723f2ddc2eb
Step 10/10 : CMD ./app
 ---> Using cache
 ---> 71995c167901
Successfully built 71995c167901
Successfully tagged alextanhongpin/hello-world:latest
```

```bash
$ docker run alextanhongpin/hello-world
Hello, go!
```

You can now build your golang image in a single step. The output is shown below:

```bash
$ docker image list | grep hello-world

alextanhongpin/hello-world-01                   latest              d678076674fa        4 minutes ago       6.55MB
alextanhongpin/hello-world-00                   latest              2669fc5303bf        8 minutes ago       729MB
alextanhongpin/hello-world                      latest              71995c167901        12 hours ago        6.54MB
```


<!--
Feedback from Chee Leong:

I think for the go app, you should put the executable to `/bin/` `/usr/bin` or `/usr/local/bin` so it’ll be not WORKDIR reliant.


[9:31] 
for the `apk` command, if the index is outdated, you might face error running that.
-->