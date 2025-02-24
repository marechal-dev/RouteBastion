package usecases

import (
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/clients/application/cryptography"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/clients/domain/entities"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/clients/domain/repositories"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/clients/dtos"
)

type CreateClientUseCase interface {
	Execute(dto *dtos.CreateUserDTO) *entities.Client
}

type createClientUseCase struct {
	repo repositories.ClientsRepository
	gen cryptography.ApiKeyGenerator
}

func NewCreateClientUseCase(repo repositories.ClientsRepository, gen cryptography.ApiKeyGenerator) *createClientUseCase {
	return &createClientUseCase{
		repo: repo,
		gen: gen,
	}
}

func (uc *createClientUseCase) Execute(dto *dtos.CreateUserDTO) *entities.Client {
	client := entities.NewClient(
		dto.Name,
		uc.gen.Generate(),
	)

	uc.repo.Create(client)

	return client
}
