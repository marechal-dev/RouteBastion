package repositories

import (
	"context"

	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/entities"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/dtos"
)

type CustomersRepository interface {
	Create(ctx context.Context, customer *entities.Customer) error
	GetOneByApiKey(apiKey string) *entities.Customer
	SaveApiKey(ctx context.Context, input *dtos.SaveApiKeyDTO) error
}
