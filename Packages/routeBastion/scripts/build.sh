#!/usr/bin/env bash

mkdir -p bin
env GOOS=linux GOARCH=amd64 go build -o bin/bastion.so cmd/bastion/main.go
