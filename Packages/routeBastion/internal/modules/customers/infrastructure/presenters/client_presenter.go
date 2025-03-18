package presenters

import (
	"time"

	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/entities"
)

type CustomerPresenter struct {
	Name string `json:"name"`
	ApiKey string `json:"apiKey"`
	BusinessIdentifier string `json:"businessIdentifier"`
	CreatedAt string `json:"createdAt"`
}

func FromDomain(customer *entities.Customer) *CustomerPresenter {
	return &CustomerPresenter{
		Name: customer.Name(),
		ApiKey: customer.ApiKey(),
		BusinessIdentifier: customer.BusinessIdentifier(),
		CreatedAt: customer.CreatedAt().Format(time.UnixDate),
	}
}
