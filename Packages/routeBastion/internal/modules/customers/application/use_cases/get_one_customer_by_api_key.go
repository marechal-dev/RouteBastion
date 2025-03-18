package usecases

import (
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/entities"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/repositories"
)

type GetOneCustomerUseCase interface {
	Execute(apiKey string) *entities.Customer
}

type GetOneCustomerUseCaseImpl struct {
	repo repositories.CustomersRepository
}

func NewGetOneCustomerUseCaseImpl(repo repositories.CustomersRepository) *GetOneCustomerUseCaseImpl {
	return &GetOneCustomerUseCaseImpl{
		repo: repo,
	}
}

func (uc *GetOneCustomerUseCaseImpl) Execute(apiKey string) *entities.Customer {
	foundCustomer := uc.repo.GetOneByApiKey(apiKey)

	if foundCustomer == nil {
		return nil
	}

	return foundCustomer
}
