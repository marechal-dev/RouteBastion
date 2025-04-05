package mappers

import (
	"time"

	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/database/generated"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/entities"
)

func ToDomain(model *generated.GetCustomerByApiKeyRow) *entities.Customer {
	var modifiedAt *time.Time = nil
	var deletedAt *time.Time = nil

	if model.ModelCustomer.ModifiedAt.Valid {
		modifiedAt = &model.ModelCustomer.ModifiedAt.Time
	}

	if model.ModelCustomer.DeletedAt.Valid {
		deletedAt = &model.ModelCustomer.DeletedAt.Time
	}

	return entities.NewCustomerFull(
		model.ModelCustomer.ID,
		model.ModelCustomer.Name,
		model.ModelCustomer.BusinessIdentifier,
		&model.ModelCustomer.CreatedAt.Time,
		modifiedAt,
		deletedAt,
	)
}
