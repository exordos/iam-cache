.PHONY: build test

build:
	go build -o iam-cache ./cmd/exordos-iam-cache

test:
	go test -race ./...
	go vet ./...
