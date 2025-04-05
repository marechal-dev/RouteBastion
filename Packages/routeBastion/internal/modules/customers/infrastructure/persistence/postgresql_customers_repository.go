package persistence

import (
	"context"

	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/database"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/database/generated"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/entities"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/infrastructure/mappers"
)

type PostgresqlCustomersRepository struct {
	queries *generated.Queries
}

func NewPostgreSQLCustomersRepository(db database.DatabaseService) *PostgresqlCustomersRepository {
	queries := db.GetQueries()

	return &PostgresqlCustomersRepository{
		queries: queries,
	}
}

func (r *PostgresqlCustomersRepository) Create(customer *entities.Customer) error {
	_, err := r.queries.CreateCustomer(context.Background(), generated.CreateCustomerParams{
		ID:                 customer.ID(),
		Name:               customer.Name(),
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
