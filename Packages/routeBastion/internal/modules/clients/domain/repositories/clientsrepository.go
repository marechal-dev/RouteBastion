package repositories

import "github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/clients/domain/entities"

type ClientsRepository interface {
	Create(client *entities.Client) error
	GetOneByApiKey(apiKey string) *entities.Client
}
