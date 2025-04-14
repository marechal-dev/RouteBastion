package repositories

import (
	"context"

	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/entities"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/dtos"
)

type CustomersRepository interface {
	Create(ctx context.Context, customer *entities.Customer) error
	SaveApiKey(ctx context.Context, input *dtos.SaveApiKeyDTO) error
	GetOneByApiKey(apiKey string) *entities.Customer
	GetOneByBusinessIdentifier(businessIdentifier string) (*entities.Customer, error)
}
