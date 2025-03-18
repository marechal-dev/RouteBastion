package persistence

import (
	"context"

	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/database"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/entities"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/infrastructure/mappers"
)

type PostgresqlCustomersRepository struct {
	queries *database.Queries
}

func NewPostgreSQLCustomersRepository(db database.Service) *PostgresqlCustomersRepository {
	queries := database.New(db.GetConn())

	return &PostgresqlCustomersRepository{
		queries: queries,
	}
}

func (r *PostgresqlCustomersRepository) Create(customer *entities.Customer) error {
	_, err := r.queries.CreateCustomer(context.Background(), database.CreateCustomerParams{
		ID: customer.ID(),
		Name: customer.Name(),
		ApiKey: customer.ApiKey(),
		BusinessIdentifier: customer.BusinessIdentifier(),
	})

	return err
}

func (r *PostgresqlCustomersRepository) GetOneByApiKey(apiKey string) *entities.Customer {
	customer, err := r.queries.GetCustomerByApiKey(context.Background(), apiKey)

	if err != nil {
		return nil
	}

	return mappers.ToDomain(&customer)
}
