package usecases

import (
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/clients/domain/entities"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/clients/domain/repositories"
)

type GetOneClientUseCase interface {
	Execute(apiKey string) *entities.Client
}

type GetOneClientUseCaseImpl struct {
	repo repositories.ClientsRepository
}

func NewGetOneClientUseCaseImpl(repo repositories.ClientsRepository) *GetOneClientUseCaseImpl {
	return &GetOneClientUseCaseImpl{
		repo: repo,
	}
}

func (uc *GetOneClientUseCaseImpl) Execute(apiKey string) *entities.Client {
	foundClient := uc.repo.GetOneByApiKey(apiKey)

	if foundClient == nil {
		return nil
	}

	return foundClient
}
