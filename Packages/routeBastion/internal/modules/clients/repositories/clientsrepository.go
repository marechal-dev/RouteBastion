package repositories

import (
	"context"

	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/database"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/clients/entities"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/clients/infrastructure/mappers"
)

type ClientsRepository interface {
	Create(client *entities.Client) error
	GetOneByApiKey(apiKey string) *entities.Client
}

type postgresqlClientsRepository struct {
	queries *database.Queries
}

func NewPostgreSQLClientsRepository(queries *database.Queries) *postgresqlClientsRepository {
	return &postgresqlClientsRepository{
		queries: queries,
	}
}

func (r *postgresqlClientsRepository) Create(client *entities.Client) error {
	_, err := r.queries.CreateClient(context.Background(), database.CreateClientParams{
		ID: client.ID(),
		Name: client.Name(),
		ApiKey: client.ApiKey(),
	})

	return err
}

func (r *postgresqlClientsRepository) GetOneByApiKey(apiKey string) *entities.Client {
	client, err := r.queries.GetClientByApiKey(context.Background(), apiKey)

	if err != nil {
		return nil
	}

	return mappers.ModelToDomain(&client)
}
