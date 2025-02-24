package persistence

import (
	"context"

	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/database"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/clients/domain/entities"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/clients/infrastructure/mappers"
)

type PostgresqlClientsRepository struct {
	queries *database.Queries
}

func NewPostgreSQLClientsRepository(db database.Service) *PostgresqlClientsRepository {
	queries := database.New(db.GetConn())

	return &PostgresqlClientsRepository{
		queries: queries,
	}
}

func (r *PostgresqlClientsRepository) Create(client *entities.Client) error {
	_, err := r.queries.CreateClient(context.Background(), database.CreateClientParams{
		ID: client.ID(),
		Name: client.Name(),
		ApiKey: client.ApiKey(),
	})

	return err
}

func (r *PostgresqlClientsRepository) GetOneByApiKey(apiKey string) *entities.Client {
	client, err := r.queries.GetClientByApiKey(context.Background(), apiKey)

	if err != nil {
		return nil
	}

	return mappers.ToDomain(&client)
}
