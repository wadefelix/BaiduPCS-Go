# TAG=`git describe --tags`
# TAG=v1.0-`date +'%Y%m%d%H%M'`
ifeq ($(VERSION),)
	VERSION=v3.6.1
endif

PREFIX=renwei/baidupcs-go
GITVERSION = $(shell git rev-parse --short HEAD)
TIMETAG:=$(shell date +'%Y%m%d%H%M')
TAG:=$(VERSION)-$(GITVERSION)-$(TIMETAG)

# GOFILES=$(shell find . -type f -regex ".*\.go" -print)
rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

dirs:=baidupcs cmd internal pcsliner pcsutil pcsverose requester vendor
GOFILES:=$(foreach dir,$(dirs),$(call rwildcard, $(dir), *.go))
#GOFILES=$(call rwildcard, alert, *.go)

build: $(GOFILES)
	GO111MODULE=on go build -a -ldflags "-w -s -X main.Version=$(TAG)" .

linux: $(GOFILES)
	CGO_ENABLED=0 GOOS=linux GO111MODULE=on go build -a -ldflags "-w -s -X main.Version=$(TAG)" -o BaiduPCS-Go .

dockerimage: linux
	@echo "🐳 $@: $(TAG)"
	@docker build -f Dockerfile -t $(PREFIX):$(TAG) .
	# @docker push $(PREFIX):$(TAG)

.PHONY: clean

clean:
	@rm -f BaiduPCS-Go.exe
	@rm -f BaiduPCS-Go
