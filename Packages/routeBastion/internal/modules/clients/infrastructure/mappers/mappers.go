package mappers

import (
	"time"

	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/database"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/clients/entities"
)

func ModelToDomain(model *database.ModelClient) *entities.Client {
	var modifiedAt *time.Time = nil
	var deletedAt *time.Time = nil

	if model.ModifiedAt.Valid {
		modifiedAt = &model.ModifiedAt.Time
	}

	if model.DeletedAt.Valid {
		deletedAt = &model.DeletedAt.Time
	}

	return entities.NewClientFull(
		model.ID,
		model.Name,
		model.ApiKey,
		&model.CreatedAt.Time,
		modifiedAt,
		deletedAt,
	)
}
