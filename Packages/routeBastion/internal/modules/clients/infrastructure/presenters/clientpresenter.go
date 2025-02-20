package presenters

import (
	"time"

	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/clients/entities"
)

type ClientPresenter struct {
	Name string `json:"name"`
	ApiKey string `json:"apiKey"`
	CreatedAt string `json:"createdAt"`
}

func FromDomain(client *entities.Client) *ClientPresenter {
	return &ClientPresenter{
		Name: client.Name(),
		ApiKey: client.ApiKey(),
		CreatedAt: client.CreatedAt().Format(time.UnixDate),
	}
}
