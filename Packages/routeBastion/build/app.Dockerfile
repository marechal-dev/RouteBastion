FROM golang:1.23.2

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

ADD internal /app/internal
ADD cmd /app/cmd
ADD scripts /app/scripts

COPY MakeFile ./
COPY app.env ./

RUN make give_permissions

RUN make all

EXPOSE 8080

CMD ["/bin/bastion.so"]
