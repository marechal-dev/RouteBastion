package dtos

import (
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/entities"
	uuid "github.com/satori/go.uuid"
)

type CreateCustomerDTO struct {
	Name               string `json:"name"               binding:"required"`
	BusinessIdentifier string `json:"businessIdentifier" binding:"required"`
}

type PersistCustomerDTO struct {
	customer *entities.Customer
	apiKey   *entities.ApiKey
}

type SaveApiKeyDTO struct {
	ApiKey     *entities.ApiKey
	CustomerID uuid.UUID
}

type GetCustomerByApiKeyDTO struct {
	ApiKey string `json:"apiKey" binding:"required,uuid4"`
}

type CreateVehicleDTO struct {
	Plate     string             `json:"plate"     binding:"required"`
	CargoType entities.CargoKind `json:"cargoType" binding:"required,cargoKind"`
	Capacity  float64            `json:"capacity"  binding:"required,min=1"`
}

type GetAllVehiclesByApiKey struct {
	ApiKey string
}
