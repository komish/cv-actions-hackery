
default: bin

.PHONY: all
all:  gomod_tidy gofmt bin test

.PHONY: gomod_tidy
gomod_tidy:
	go mod tidy

.PHONY: gofmt
gofmt:
	go fmt -x ./...

.PHONY: bin
bin:
	 go build -o ./out/chart-verifier main.go

.PHONY: bin_win
bin_win:
	env GOOS=windows GOARCH=amd64 go build -o .\out\chart-verifier.exe main.go

.PHONY: test
test:
	go test -v ./...

.PHONY: build-image
build-image:
	hack/build-image.sh

.PHONY: sec
sec: gosec
	# Run this command to install gosec, if not installed:
	# export PATH=$PATH:$(go env GOPATH)/bin
	# go install github.com/securego/gosec/v2/cmd/gosec@latest
	$(GOSEC) -no-fail -fmt=sarif -out=gosec.sarif -exclude-dir tests ./...

.PHONY: lint
lint: golangci-lint ## Run golangci-lint linter checks. Auto passes for now.
	$(GOLANGCI_LINT) run || true 

# Install golangci_lint in a project-local directory
GOLANGCI_LINT = $(shell pwd)/bin/golangci-lint
GOLANGCI_LINT_VERSION ?= v1.50.0
golangci-lint: $(GOLANGCI_LINT)
$(GOLANGCI_LINT):
	$(call go-install-tool,$(GOLANGCI_LINT),github.com/golangci/golangci-lint/cmd/golangci-lint@$(GOLANGCI_LINT_VERSION))


# Install gosec in a project-local directory.
GOSEC = $(shell pwd)/bin/gosec
GOSEC_VERSION ?= latest
gosec: $(GOSEC)
$(GOSEC):
	$(call go-install-tool,$(GOSEC),github.com/securego/gosec/v2/cmd/gosec@$(GOSEC_VERSION))


# go-install-tool will 'go install' any package $2 and install it to $1.
PROJECT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
define go-install-tool
@[ -f $(1) ] || { \
GOBIN=$(PROJECT_DIR)/bin go install $(2) ;\
}
endef