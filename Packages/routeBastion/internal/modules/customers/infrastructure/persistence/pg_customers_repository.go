package persistence

import (
	"context"

	infraDB "github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/infrastructure/database"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/infrastructure/database/generated"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/entities"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/dtos"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/infrastructure/mappers"
	infraShared "github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/shared/infrastructure"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/platform/database"
)

type PGCustomersRepository struct {
	queries *generated.Queries
}

func NewPGCustomersRepository(db database.DBProvider) *PGCustomersRepository {
	return &PGCustomersRepository{
		queries: generated.New(db.GetConn()),
	}
}

func (r *PGCustomersRepository) Create(ctx context.Context, customer *entities.Customer) error {
	tx, err := infraDB.ExtractTx(ctx)
	if err != nil {
		return err
	}

	q := r.queries.WithTx(tx)

	_, err = q.CreateCustomer(ctx, generated.CreateCustomerParams{
		ID:                 customer.ID(),
		Name:               customer.Name(),
		BusinessIdentifier: customer.BusinessIdentifier(),
	})

	return err
}

func (r *PGCustomersRepository) GetOneByApiKey(apiKey string) *entities.Customer {
	row, err := r.queries.GetCustomerByApiKey(context.Background(), apiKey)

	if err != nil {
		return nil
	}

	// TODO: Fetch Vehicles here
	return mappers.ToDomain(row.ModelCustomer, row.ModelApiKey, make([]generated.ModelVehicle, 0))
}

func (r *PGCustomersRepository) GetOneByBusinessIdentifier(
	businessIdentifier string,
) (*entities.Customer, error) {
	row, err := r.queries.GetOneCustomerByBusinessIdentifier(
		context.Background(),
		businessIdentifier,
	)

	if err != nil {
		return nil, err
	}

	return mappers.ToDomain(
		row.ModelCustomer,
		row.ModelApiKey,
		make([]generated.ModelVehicle, 0),
	), nil
}

func (r *PGCustomersRepository) SaveApiKey(ctx context.Context, input *dtos.SaveApiKeyDTO) error {
	tx, err := infraDB.ExtractTx(ctx)
	if err != nil {
		return err
	}

	q := r.queries.WithTx(tx)

	createdAt := infraShared.ConvertTimeToPgtypeTimestamp(*input.ApiKey.CreatedAt())

	_, err = q.CreateApiKey(ctx, generated.CreateApiKeyParams{
		ID:         input.ApiKey.ID(),
		Key:        input.ApiKey.Key(),
		CustomerID: input.CustomerID,
		CreatedAt:  createdAt,
	})

	return err
}
