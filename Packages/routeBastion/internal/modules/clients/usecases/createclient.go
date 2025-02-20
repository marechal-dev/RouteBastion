package usecases

import (
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/clients/dtos"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/clients/entities"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/clients/repositories"
)

type CreateClientUseCase interface {
	Execute(dto *dtos.CreateUserDTO) *entities.Client
}

type createClientUseCase struct {
	repo repositories.ClientsRepository
}

func NewCreateClientUseCase(repo repositories.ClientsRepository) *createClientUseCase {
	return &createClientUseCase{
		repo: repo,
	}
}

func (uc *createClientUseCase) Execute(dto *dtos.CreateUserDTO) *entities.Client {
	client := entities.NewClient(
		dto.Name,
		"",
	)

	uc.repo.Create(client)

	return client
}
