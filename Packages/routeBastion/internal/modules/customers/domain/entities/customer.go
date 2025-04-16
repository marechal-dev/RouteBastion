package entities

import (
	"errors"
	"time"

	"slices"

	uuid "github.com/satori/go.uuid"
)

type Customer struct {
	id                 uuid.UUID
	name               string
	businessIdentifier string

	apiKey   *ApiKey
	vehicles []*Vehicle

	createdAt  *time.Time
	modifiedAt *time.Time
	deletedAt  *time.Time
}

func NewCustomer(
	name string,
	businessIdentifier string,
	apiKey *ApiKey,
) *Customer {
	now := time.Now()

	return &Customer{
		id:                 uuid.NewV4(),
		name:               name,
		businessIdentifier: businessIdentifier,

		apiKey:   apiKey,
		vehicles: []*Vehicle{},

		createdAt:  &now,
		modifiedAt: nil,
		deletedAt:  nil,
	}
}

func RehydrateCustomer(
	id uuid.UUID,
	name string,
	businessIdentifier string,
	apiKey *ApiKey,
	vehicles []*Vehicle,
	createdAt *time.Time,
	modifiedAt *time.Time,
	deletedAt *time.Time,
) *Customer {
	return &Customer{
		id:                 id,
		name:               name,
		businessIdentifier: businessIdentifier,

		apiKey:   apiKey,
		vehicles: vehicles,

		createdAt:  createdAt,
		modifiedAt: modifiedAt,
		deletedAt:  deletedAt,
	}
}

func (c *Customer) ID() uuid.UUID {
	return c.id
}

func (c *Customer) Name() string {
	return c.name
}

func (c *Customer) SetName(name string) {
	c.name = name
	c.touch()
}

func (c *Customer) BusinessIdentifier() string {
	return c.businessIdentifier
}

func (c *Customer) AddVehicle(vehicle *Vehicle) error {
	for _, v := range c.vehicles {
		if v.ID().String() == vehicle.ID().String() {
			return errors.New("vehicle already added")
		}
	}

	c.vehicles = append(c.vehicles, vehicle)
	c.touch()

	return nil
}

func (c *Customer) RemoveVehicle(vehicleID string) error {
	for i, v := range c.vehicles {
		if v.ID().String() == vehicleID {
			c.vehicles = slices.Delete(c.vehicles, i, i+1)
			c.touch()

			return nil
		}
	}

	return errors.New("vehicle not found")
}

func (c *Customer) ApiKey() *ApiKey {
	return c.apiKey
}

func (c *Customer) SetApiKey(key *ApiKey) error {
	if key == nil {
		return errors.New("api key cannot be nil")
	}

	c.apiKey = key
	c.touch()

	return nil
}

func (c *Customer) CreatedAt() *time.Time {
	return c.createdAt
}

func (c *Customer) ModifiedAt() *time.Time {
	return c.modifiedAt
}

func (c *Customer) DeletedAt() *time.Time {
	return c.deletedAt
}

func (c *Customer) Disable() {
	now := time.Now()
	c.deletedAt = &now
	c.touch()
}

func (c *Customer) IsDisabled() bool {
	if c.deletedAt == nil {
		return false
	}

	nowUNIX := time.Now().Unix()

	return c.deletedAt.Unix() > nowUNIX
}

func (c *Customer) touch() {
	now := time.Now()
	c.modifiedAt = &now
}
