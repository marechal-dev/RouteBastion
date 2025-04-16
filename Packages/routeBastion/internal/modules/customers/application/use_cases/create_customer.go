package usecases

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/application/cryptography"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/entities"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/repositories"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/dtos"
	sharedErrors "github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/shared/errors"
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
	customer, err := uc.repo.GetOneByBusinessIdentifier(dto.BusinessIdentifier)

	if err != nil && !errors.Is(err, pgx.ErrNoRows) {
		return nil, sharedErrors.InfrastructureError{
			Code: sharedErrors.ErrCodeDatabaseFailure,
			Msg:  err.Error(),
		}
	}

	if customer != nil {
		return nil, sharedErrors.ApplicationError{
			Code: sharedErrors.ErrCodeConflict,
			Msg:  "customer already exists",
		}
	}

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
				return nil, sharedErrors.InfrastructureError{
					Code: sharedErrors.ErrCodeDatabaseFailure,
					Msg:  err.Error(),
				}
			}

			err = uc.repo.SaveApiKey(txCtx, &dtos.SaveApiKeyDTO{
				ApiKey:     apiKey,
				CustomerID: customer.ID(),
			})
			if err != nil {
				return nil, sharedErrors.InfrastructureError{
					Code: sharedErrors.ErrCodeDatabaseFailure,
					Msg:  err.Error(),
				}
			}

			return customer, nil
		},
	)
}
