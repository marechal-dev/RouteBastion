package repositories

import "github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/entities"

type VehiclesRepository interface {
	CreateOne(vehicle *entities.Vehicle) (*entities.Vehicle, error)
	GetManyVehiclesByCustomerID(customerID string) []*entities.Vehicle
	DeleteOneByID(vehicleID string) error
}
