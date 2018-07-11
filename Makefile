# For a shorter version
# git rev-parse --short HEAD

VERSION := $(shell git rev-parse HEAD)

BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
# $ date -R
# Wed, 11 Jul 2018 10:25:26 +0800

# $ date -u +"%Y-%m-%dT%H:%M:%SZ"
# 2018-07-11T02:25:23Z

VCS_URL := $(shell git config --get remote.origin.url)

VCS_REF := $(shell git log -1 --pretty=%h)

NAME := $(shell basename `git rev-parse --show-toplevel`)
VENDOR := $(shell whoami)

print:
	@echo VERSION=${VERSION} 
	@echo BUILD_DATE=${BUILD_DATE}
	@echo VCS_URL=${VCS_URL}
	@echo VCS_REF=${VCS_REF}
	@echo NAME=${NAME}
	@echo VENDOR=${VENDOR}

build:
	docker build -t alextanhongpin/hello-go --build-arg VERSION="${VERSION}" \
	--build-arg BUILD_DATE="${BUILD_DATE}" \
	--build-arg VCS_URL="${VCS_URL}" \
	--build-arg VCS_REF="${VCS_REF}" \
	--build-arg NAME="${NAME}" \
	--build-arg VENDOR="${VENDOR}" .

run:
	@docker run alextanhongpin/hello-go

label:
	@docker inspect --format='{{range $k, $v := .Config.Labels}}{{$k}}={{$v}}{{println}}{{end}}' alextanhongpin/hello-go
