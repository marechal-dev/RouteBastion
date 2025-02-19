package database_test

import (
	"context"
	"log"
	"testing"
	"time"

	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/database"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/modules/postgres"
	"github.com/testcontainers/testcontainers-go/wait"
)

func mustStartPostgresContainer() (func(context.Context, ...testcontainers.TerminateOption) error, error) {
	var (
		dbName = "route_bastion_test"
		dbPwd  = "docker"
		dbUser = "docker"
	)

	dbContainer, err := postgres.Run(
		context.Background(),
		"postgres:latest",
		postgres.WithDatabase(dbName),
		postgres.WithUsername(dbUser),
		postgres.WithPassword(dbPwd),
		testcontainers.WithWaitStrategy(
			wait.ForLog("database system is ready to accept connections").
				WithOccurrence(2).
				WithStartupTimeout(5*time.Second)),
	)
	if err != nil {
		return nil, err
	}


	_, err = dbContainer.Host(context.Background())
	if err != nil {
		return dbContainer.Terminate, err
	}

	_, err = dbContainer.MappedPort(context.Background(), "5432/tcp")
	if err != nil {
		return dbContainer.Terminate, err
	}

	return dbContainer.Terminate, err
}

func TestMain(m *testing.M) {
	teardown, err := mustStartPostgresContainer()
	if err != nil {
		log.Fatalf("could not start postgres container: %v", err)
	}

	m.Run()

	if teardown != nil && teardown(context.Background()) != nil {
		log.Fatalf("could not teardown postgres container: %v", err)
	}
}

func TestNew(t *testing.T) {
	var (
		dbName = "route_bastion_test"
		dbPwd  = "docker"
		dbUser = "docker"
		dbPort = "5432"
		dbHost = "localhost"
		dbSchema = "public"
	)
	srv := database.NewDatabaseService(
		dbName,
		dbPwd,
		dbUser,
		dbPort,
		dbHost,
		dbSchema,
	)
	if srv == nil {
		t.Fatal("New() returned nil")
	}
}

func TestHealth(t *testing.T) {
	var (
		dbName = "route_bastion_test"
		dbPwd  = "docker"
		dbUser = "docker"
		dbPort = "5432"
		dbHost = "localhost"
		dbSchema = "public"
	)
	srv := database.NewDatabaseService(
		dbName,
		dbPwd,
		dbUser,
		dbPort,
		dbHost,
		dbSchema,
	)

	stats := srv.Health()

	if stats["status"] != "up" {
		t.Fatalf("expected status to be up, got %s", stats["status"])
	}

	if _, ok := stats["error"]; ok {
		t.Fatalf("expected error not to be present")
	}

	if stats["message"] != "It's healthy" {
		t.Fatalf("expected message to be 'It's healthy', got %s", stats["message"])
	}
}

func TestClose(t *testing.T) {
	var (
		dbName = "route_bastion_test"
		dbPwd  = "docker"
		dbUser = "docker"
		dbPort = "5432"
		dbHost = "localhost"
		dbSchema = "public"
	)
	srv := database.NewDatabaseService(
		dbName,
		dbPwd,
		dbUser,
		dbPort,
		dbHost,
		dbSchema,
	)

	if srv.Close() != nil {
		t.Fatalf("expected Close() to return nil")
	}
}
