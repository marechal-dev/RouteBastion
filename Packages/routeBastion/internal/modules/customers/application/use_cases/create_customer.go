package usecases

import (
	"context"
	"fmt"

	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/application/cryptography"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/entities"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/repositories"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/dtos"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/platform/database"
)

type CreateCustomerUseCase interface {
	Execute(ctx context.Context, dto *dtos.CreateCustomerDTO) (*entities.Customer, error)
}

type CreateCustomerUseCaseImpl struct {
	tx   database.TxManager
	repo repositories.CustomersRepository
	gen  cryptography.ApiKeyGenerator
}

func NewCreateCustomerUseCase(
	tx database.TxManager,
	repo repositories.CustomersRepository,
	gen cryptography.ApiKeyGenerator,
) *CreateCustomerUseCaseImpl {
	return &CreateCustomerUseCaseImpl{
		tx:   tx,
		repo: repo,
		gen:  gen,
	}
}

func (uc *CreateCustomerUseCaseImpl) Execute(
	ctx context.Context,
	dto *dtos.CreateCustomerDTO,
) (*entities.Customer, error) {
	return database.WithinTransactionReturning(
		uc.tx,
		ctx,
		func(txCtx context.Context) (*entities.Customer, error) {
			key := uc.gen.Generate()
			apiKey := entities.NewApiKey(key)
			customer := entities.NewCustomer(
				dto.Name,
				dto.BusinessIdentifier,
				apiKey,
			)

			err := uc.repo.Create(txCtx, customer)
			if err != nil {
				return nil, err
			}

			fmt.Printf("customer: %v", err)

			err = uc.repo.SaveApiKey(txCtx, &dtos.SaveApiKeyDTO{
				ApiKey:     apiKey,
				CustomerID: customer.ID(),
			})
			if err != nil {
				return nil, err
			}

			fmt.Printf("api key: %v", err)

			return customer, nil
		},
	)
}
