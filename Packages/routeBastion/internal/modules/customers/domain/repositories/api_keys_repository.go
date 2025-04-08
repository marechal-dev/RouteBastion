package repositories

import "github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/entities"

type ApiKeysRepository interface {
	Create(apiKey *entities.ApiKey)
	Save(apiKey *entities.ApiKey)
	DeleteOneByID(id string)
}
