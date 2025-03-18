package entities

import (
	"time"

	uuid "github.com/satori/go.uuid"
)

type Customer struct {
	id uuid.UUID
	name string
	apiKey string
	businessIdentifier string
	createdAt *time.Time
	modifiedAt *time.Time
	deletedAt *time.Time
}

func NewCustomer(
	name string,
	apiKey string,
	businessIdentifier string,
) *Customer {
	return &Customer{
		id: uuid.NewV4(),
		name: name,
		apiKey: apiKey,
		businessIdentifier: businessIdentifier,
		createdAt: &time.Time{},
		modifiedAt: nil,
		deletedAt: nil,
	}
}

func NewCustomerFull(
	id uuid.UUID,
	name string,
	apiKey string,
	businessIdentifier string,
	createdAt *time.Time,
	modifiedAt *time.Time,
	deletedAt *time.Time,
) *Customer {
	return &Customer{
		id: id,
		name: name,
		apiKey: apiKey,
		businessIdentifier: businessIdentifier,
		createdAt: createdAt,
		modifiedAt: modifiedAt,
		deletedAt: deletedAt,
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

func (c *Customer) ApiKey() string {
	return c.apiKey
}

func (c *Customer) SetApiKey(apiKey string) {
	c.apiKey = apiKey
	c.touch()
}

func (c *Customer) BusinessIdentifier() string {
	return c.businessIdentifier
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
	c.deletedAt = &time.Time{}
	c.touch()
}

func (c *Customer) IsDisabled() bool {
	if c.deletedAt == nil {
		return false
	}

	now := &time.Time{}
	nowUNIX := now.Unix()

	return c.deletedAt.Unix() > nowUNIX
}

func (c *Customer) touch() {
	c.modifiedAt = &time.Time{}
}
