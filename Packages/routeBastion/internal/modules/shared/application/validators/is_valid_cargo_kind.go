package validators

import (
	"github.com/go-playground/validator/v10"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/domain/entities"
)

func IsValidCargoKind(fl validator.FieldLevel) bool {
	cargoKind := fl.Field().String()
	switch entities.CargoKind(cargoKind) {
	case entities.CargoKindBulkCargo,
		entities.CargoKindContainerizedCargo,
		entities.CargoKindRefrigeratedCargo,
		entities.CargoKindDryCargo,
		entities.CargoKindAliveCargo,
		entities.CargoKindDangerousCargo,
		entities.CargoKindFragileCargo,
		entities.CargoKindIndivisibleAndExceptionalCargo,
		entities.CargoKindVehicleCargo:
		return true
	}

	return false
}
