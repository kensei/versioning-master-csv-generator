INTERNAL_BIN_DIR=_internal_bin
GOVERSION=$(shell go version)
THIS_GOOS=$(word 1,$(subst /, ,$(lastword $(GOVERSION))))
THIS_GOARCH=$(word 2,$(subst /, ,$(lastword $(GOVERSION))))
GOOS=$(THIS_GOOS)
GOARCH=$(THIS_GOARCH)
VERSION=$(patsubst "%",%,$(lastword $(shell grep 'const version' vmcg.go)))
RELEASE_DIR=releases
ARTIFACTS_DIR=$(RELEASE_DIR)/artifacts/$(VERSION)
SRC_FILES = $(wildcard *.go cmd/vmcg/*.go)
BUILD_TARGETS= \
	build-linux-amd64 \
	build-linux-arm64 \
	build-darwin-amd64 \
	build-darwin-arm64 \
	build-windows-amd64
RELEASE_TARGETS=\
	release-linux-amd64 \
	release-linux-arm64 \
	release-darwin-amd64 \
	release-darwin-arm64 \
	release-windows-amd64
COPY_TARGETS=\
	copy_darwin \
    copy_linux

COPY_BIN_DIR = ../
TEMPLATE_DIR=./test_templates

.PHONY: clean build $(RELEASE_TARGETS) $(BUILD_TARGETS) $(RELEASE_DIR)/$(GOOS)/$(GOARCH)/vmcg$(SUFFIX)

build: $(RELEASE_DIR)/vmcg_$(GOOS)_$(GOARCH)/vmcg$(SUFFIX)

deps:
	@echo "Downloading dependencies..."
	@go mod tidy
	@GO111MODULE=on go mod download

build-windows-amd64:
	@$(MAKE) build GOOS=windows GOARCH=amd64 SUFFIX=.exe

build-linux-amd64:
	@$(MAKE) build GOOS=linux GOARCH=amd64

build-linux-arm64:
	@$(MAKE) build GOOS=linux GOARCH=arm64

build-darwin-amd64:
	@$(MAKE) build GOOS=darwin GOARCH=amd64

build-darwin-arm64:
	@$(MAKE) build GOOS=darwin GOARCH=arm64

$(RELEASE_DIR)/vmcg_$(GOOS)_$(GOARCH)/vmcg$(SUFFIX): deps
	@GO111MODULE=on go build -o $(RELEASE_DIR)/vmcg_$(GOOS)_$(GOARCH)/vmcg$(SUFFIX) cmd/vmcg/vmcg.go

all: $(BUILD_TARGETS)

release: $(RELEASE_TARGETS)

$(RELEASE_DIR)/vmcg_$(GOOS)_$(GOARCH)/Changes:
	@cp Changes $(RELEASE_DIR)/vmcg_$(GOOS)_$(GOARCH)

$(RELEASE_DIR)/vmcg_$(GOOS)_$(GOARCH)/README.md:
	@cp README.md $(RELEASE_DIR)/vmcg_$(GOOS)_$(GOARCH)

release-changes: $(RELEASE_DIR)/vmcg_$(GOOS)_$(GOARCH)/Changes
release-readme: $(RELEASE_DIR)/vmcg_$(GOOS)_$(GOARCH)/README.md

release-windows-amd64: build-windows-amd64
	@$(MAKE) release-changes release-readme release-zip GOOS=windows GOARCH=amd64

release-linux-amd64: build-linux-amd64
	@$(MAKE) release-changes release-readme release-targz GOOS=linux GOARCH=amd64

release-linux-arm64: build-linux-arm64
	@$(MAKE) release-changes release-readme release-targz GOOS=linux GOARCH=arm64

release-darwin-amd64: build-darwin-amd64
	@$(MAKE) release-changes release-readme release-zip GOOS=darwin GOARCH=amd64

release-darwin-arm64: build-darwin-arm64
	@$(MAKE) release-changes release-readme release-zip GOOS=darwin GOARCH=arm64

$(ARTIFACTS_DIR):
	@mkdir -p $(ARTIFACTS_DIR)

# note: I dreamt of using tar.bz2 for my releases, but then historically
# (for whatever reason that is unknwon to me now) I was creating .zip for
# darwin/windows, and .tar.gz for linux, so I guess we'll stick with those.
# (I think this is from goxc days)
release-tarbz: $(ARTIFACTS_DIR)
	tar -cjf $(ARTIFACTS_DIR)/vmcg_$(GOOS)_$(GOARCH).tar.bz2 -C $(RELEASE_DIR) vmcg_$(GOOS)_$(GOARCH)

release-targz: $(ARTIFACTS_DIR)
	tar -czf $(ARTIFACTS_DIR)/vmcg_$(GOOS)_$(GOARCH).tar.gz -C $(RELEASE_DIR) vmcg_$(GOOS)_$(GOARCH)

release-zip: $(ARTIFACTS_DIR)
	cd $(RELEASE_DIR) && zip -9 $(CURDIR)/$(ARTIFACTS_DIR)/vmcg_$(GOOS)_$(GOARCH).zip vmcg_$(GOOS)_$(GOARCH)/*

release-github-token: github_token
	@echo "file `github_token` is required"

release-upload: release release-github-token
	ghr -u $(GITHUB_USERNAME) -t $(shell cat github_token) --draft --replace $(VERSION) $(ARTIFACTS_DIR)

test: deps
	@echo "Running tests..."
	@GO111MODULE=on PATH=$(INTERNAL_BIN_DIR)/$(GOOS)/$(GOARCH):$(PATH) go test -v ./...

clean:
	-rm -rf $(RELEASE_DIR)/*/*
	-rm -rf $(ARTIFACTS_DIR)/*

copy: $(COPY_TARGETS)

copy_darwin: build-darwin-amd64
	@cp $(RELEASE_DIR)/vmcg_darwin_amd64/vmcg$(SUFFIX) $(COPY_BIN_DIR)/vmcg
	@cp $(RELEASE_DIR)/vmcg_darwin_arm64/vmcg$(SUFFIX) $(COPY_BIN_DIR)/vmcg_darwin_arm64
	@echo "copied to $(COPY_BIN_DIR)"

copy_linux: build-linux-amd64 build-linux-arm64
	@cp $(RELEASE_DIR)/vmcg_linux_amd64/vmcg$(SUFFIX) $(COPY_BIN_DIR)/vmcg_linux
	@cp $(RELEASE_DIR)/vmcg_linux_arm64/vmcg$(SUFFIX) $(COPY_BIN_DIR)/vmcg_linux_arm64
	@echo "copied to $(COPY_BIN_DIR)"

run-example: deps
	-rm -rf ./example/generated
	go run cmd/vmcg/vmcg.go gencontroller \
    --output "generated" \
    --importpath ./proto-vendor
