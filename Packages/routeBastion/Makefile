.PHONY: all give_permissions clean run migrate

all: clean build run

run:
	./bin/bastion.so

build:
	./scripts/build.sh

migrate:
	./scripts/migrate_down.sh
	./scripts/migrate_up.sh

give_permissions:
	chmod +x ./scripts/build.sh
	chmod +x ./scripts/clean.sh
	chmod +x ./scripts/migrate_up.sh
	chmod +x ./scripts/migrate_down.sh

clean:
	./scripts/clean.sh
