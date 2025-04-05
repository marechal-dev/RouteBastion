package usecases

import (
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/application/cryptography"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/entities"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/repositories"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/dtos"
)

type CreateCustomerUseCase interface {
	Execute(dto *dtos.CreateCustomerDTO) *entities.Customer
}

type CreateCustomerUseCaseImpl struct {
	repo repositories.CustomersRepository
	gen  cryptography.ApiKeyGenerator
}

func NewCreateCustomerUseCase(
	repo repositories.CustomersRepository,
	gen cryptography.ApiKeyGenerator,
) *CreateCustomerUseCaseImpl {
	return &CreateCustomerUseCaseImpl{
		repo: repo,
		gen:  gen,
	}
}

func (uc *CreateCustomerUseCaseImpl) Execute(dto *dtos.CreateCustomerDTO) *entities.Customer {
	customer := entities.NewCustomer(
		dto.Name,
		dto.BusinessIdentifier,
	)

	uc.repo.Create(customer)

	return customer
}
