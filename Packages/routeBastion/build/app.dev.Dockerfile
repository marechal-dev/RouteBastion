FROM golang:1.24.0

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

RUN go install github.com/air-verse/air@latest

ADD internal /app/internal
ADD cmd /app/cmd
ADD scripts /app/scripts

COPY .air.toml ./
COPY Makefile ./
COPY app.env ./

EXPOSE 8080

CMD ["air"]
