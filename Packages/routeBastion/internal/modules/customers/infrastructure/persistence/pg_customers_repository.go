package persistence

import (
	"context"

	"github.com/jackc/pgx/v5/pgtype"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/infrastructure/database/generated"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/entities"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/dtos"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/infrastructure/mappers"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/platform/database"
)

type PGCustomersRepository struct {
	queries *generated.Queries
	tx      database.TxManager
}

func NewPGCustomersRepository(db database.DBProvider) *PGCustomersRepository {
	queries := generated.New(db.GetConn())

	return &PGCustomersRepository{
		queries: queries,
	}
}

func (r *PGCustomersRepository) Create(ctx context.Context, customer *entities.Customer) error {
	_, err := r.queries.CreateCustomer(ctx, generated.CreateCustomerParams{
		ID:                 customer.ID(),
		Name:               customer.Name(),
		BusinessIdentifier: customer.BusinessIdentifier(),
	})

	return err
}

func (r *PGCustomersRepository) GetOneByApiKey(apiKey string) *entities.Customer {
	customer, err := r.queries.GetCustomerByApiKey(context.Background(), apiKey)

	if err != nil {
		return nil
	}

	return mappers.ToDomain(&customer)
}

func (r *PGCustomersRepository) SaveApiKey(ctx context.Context, input *dtos.SaveApiKeyDTO) error {
	_, err := r.queries.CreateApiKey(ctx, generated.CreateApiKeyParams{
		ID:         input.ApiKey.ID(),
		Key:        input.ApiKey.Key(),
		CustomerID: input.CustomerID,
		CreatedAt: pgtype.Timestamp{
			Time: *input.ApiKey.CreatedAt(),
		},
	})

	return err
}
