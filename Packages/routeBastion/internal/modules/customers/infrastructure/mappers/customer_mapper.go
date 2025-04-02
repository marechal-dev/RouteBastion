package mappers

import (
	"time"

	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/database"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/entities"
)

func ToDomain(model *database.ModelCustomer) *entities.Customer {
	var modifiedAt *time.Time = nil
	var deletedAt *time.Time = nil

	if model.ModifiedAt.Valid {
		modifiedAt = &model.ModifiedAt.Time
	}

	if model.DeletedAt.Valid {
		deletedAt = &model.DeletedAt.Time
	}

	return entities.NewCustomerFull(
		model.ID,
		model.Name,
		model.ApiKey,
		model.BusinessIdentifier,
		&model.CreatedAt.Time,
		modifiedAt,
		deletedAt,
	)
}
