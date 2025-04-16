package presenters

import (
	"time"

	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/entities"
)

type CustomerPresenter struct {
	Name               string     `json:"name"`
	BusinessIdentifier string     `json:"businessIdentifier"`
	ApiKey             string     `json:"apiKey"`
	CreatedAt          *time.Time `json:"createdAt"`
}

func FromDomain(customer *entities.Customer) *CustomerPresenter {
	return &CustomerPresenter{
		Name:               customer.Name(),
		BusinessIdentifier: customer.BusinessIdentifier(),
		ApiKey:             customer.ApiKey().Key(),
		CreatedAt:          customer.CreatedAt(),
	}
}
