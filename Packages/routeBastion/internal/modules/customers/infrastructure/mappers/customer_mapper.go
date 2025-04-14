package mappers

import (
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/infrastructure/database/generated"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/entities"
)

func ToDomain(
	rawCustomer generated.ModelCustomer,
	rawApiKey generated.ModelApiKey,
	rawVehicles []generated.ModelVehicle,
) *entities.Customer {
	apiKey := entities.RehydrateApiKey(
		rawApiKey.ID,
		rawApiKey.Key,
		&rawApiKey.CreatedAt.Time,
		&rawApiKey.ModifiedAt.Time,
		&rawApiKey.DeletedAt.Time,
	)

	return entities.RehydrateCustomer(
		rawCustomer.ID,
		rawCustomer.Name,
		rawCustomer.BusinessIdentifier,
		apiKey,
		[]*entities.Vehicle{},
		&rawApiKey.CreatedAt.Time,
		&rawApiKey.ModifiedAt.Time,
		&rawApiKey.DeletedAt.Time,
	)
}
