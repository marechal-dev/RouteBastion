package entities

import (
	"time"

	uuid "github.com/satori/go.uuid"
)

type CargoKind string

const (
	CargoKindBulkCargo                      CargoKind = "bulk_cargo"
	CargoKindContainerizedCargo             CargoKind = "containerized_cargo"
	CargoKindRefrigeratedCargo              CargoKind = "refrigerated_cargo"
	CargoKindDryCargo                       CargoKind = "dry_cargo"
	CargoKindAliveCargo                     CargoKind = "alive_cargo"
	CargoKindDangerousCargo                 CargoKind = "dangerous_cargo"
	CargoKindFragileCargo                   CargoKind = "fragile_cargo"
	CargoKindIndivisibleAndExceptionalCargo CargoKind = "indivisible_and_exceptional_cargo"
	CargoKindVehicleCargo                   CargoKind = "vehicle_cargo"
)

type Vehicle struct {
	id         uuid.UUID
	plate      string
	cargoType  CargoKind
	capacity   float64
	createdAt  *time.Time
	modifiedAt *time.Time
	deletedAt  *time.Time
}

func NewVehicle(
	plate string,
	capacity float64,
	cargoType CargoKind,
) *Vehicle {
	now := time.Now()

	return &Vehicle{
		id:         uuid.NewV4(),
		plate:      plate,
		capacity:   capacity,
		cargoType:  cargoType,
		createdAt:  &now,
		modifiedAt: nil,
		deletedAt:  nil,
	}
}

func RehydrateVehicle(
	id uuid.UUID,
	plate string,
	capacity float64,
	cargoType CargoKind,
	createdAt *time.Time,
	modifiedAt *time.Time,
	deletedAt *time.Time,
) *Vehicle {
	return &Vehicle{
		id:         id,
		plate:      plate,
		capacity:   capacity,
		cargoType:  cargoType,
		createdAt:  createdAt,
		modifiedAt: modifiedAt,
		deletedAt:  deletedAt,
	}
}

func (v *Vehicle) ID() uuid.UUID {
	return v.id
}

func (v *Vehicle) Plate() string {
	return v.plate
}

func (v *Vehicle) SetPlate(plate string) {
	v.plate = plate
	v.touch()
}

func (v *Vehicle) Capacity() float64 {
	return v.capacity
}

func (v *Vehicle) SetCapacity(capacity float64) {
	v.capacity = capacity
	v.touch()
}

func (v *Vehicle) CargoType() CargoKind {
	return v.cargoType
}

func (v *Vehicle) CreatedAt() *time.Time {
	return v.createdAt
}

func (v *Vehicle) ModifiedAt() *time.Time {
	return v.modifiedAt
}

func (v *Vehicle) DeletedAt() *time.Time {
	return v.deletedAt
}

func (v *Vehicle) Disable() {
	now := time.Now()
	v.deletedAt = &now
	v.touch()
}

func (v *Vehicle) IsDisabled() bool {
	if v.deletedAt == nil {
		return false
	}

	now := time.Now()
	nowUNIX := now.Unix()

	return v.deletedAt.Unix() > nowUNIX
}

func (v *Vehicle) touch() {
	now := time.Now()
	v.modifiedAt = &now
}
