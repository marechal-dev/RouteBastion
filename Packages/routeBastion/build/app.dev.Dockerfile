FROM golang:1.24.0-alpine

WORKDIR /app

RUN go install github.com/air-verse/air@latest

COPY go.mod go.sum ./
RUN go mod download

ADD cmd ./cmd
ADD scripts ./scripts
ADD internal ./internal
ADD database ./database

COPY .air.toml ./
COPY sqlc.yml ./
COPY app.env ./

EXPOSE 8080

CMD ["air"]
