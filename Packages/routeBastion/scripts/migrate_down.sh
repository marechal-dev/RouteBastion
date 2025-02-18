#!/usr/bin/env bash

migrate -path database/migrations -database "postgresql://docker:docker@localhost:5432/route_bastion?sslmode=disable&search_path=public" down
