FROM golang:1.24.0-alpine AS build

WORKDIR /app

RUN go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest

COPY go.mod go.sum ./
RUN go mod download

ADD cmd /app/cmd
ADD scripts /app/scripts
ADD internal /app/internal
ADD database /app/database

COPY sqlc.yml ./
COPY app.env ./

RUN sqlc generate

RUN make give_permissions
RUN make all

FROM scratch

WORKDIR /app

COPY --from=build /app/bin/bastion.so ./bin/bastion.so

EXPOSE 8080

ENTRYPOINT ["/bin/bastion.so"]
