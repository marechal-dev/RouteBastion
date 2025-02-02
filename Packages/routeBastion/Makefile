.PHONY: all give_permissions clean

all: clean build run

run:
	./bin/bastion.so

build:
	./scripts/build.sh

give_permissions:
	chmod +x ./scripts/build.sh
	chmod +x ./scripts/clean.sh

clean:
	./scripts/clean.sh
