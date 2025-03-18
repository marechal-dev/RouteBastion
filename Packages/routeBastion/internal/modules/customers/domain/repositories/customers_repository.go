package repositories

import "github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/entities"

type CustomersRepository interface {
	Create(customer *entities.Customer) error
	GetOneByApiKey(apiKey string) *entities.Customer
}
