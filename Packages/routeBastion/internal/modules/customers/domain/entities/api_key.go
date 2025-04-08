package entities

import (
	"time"

	uuid "github.com/satori/go.uuid"
)

type ApiKey struct {
	id         uuid.UUID
	key        string
	customerID uuid.UUID
	createdAt  *time.Time
	modifiedAt *time.Time
	deletedAt  *time.Time
}

func NewApiKey(
	key string,
	customerID uuid.UUID,
) *ApiKey {
	return &ApiKey{
		id:         uuid.NewV4(),
		key:        key,
		customerID: customerID,
		createdAt:  &time.Time{},
		modifiedAt: nil,
		deletedAt:  nil,
	}
}

func NewFullApiKey(
	id uuid.UUID,
	key string,
	customerID uuid.UUID,
	createdAt *time.Time,
	modifiedAt *time.Time,
	deletedAt *time.Time,
) *ApiKey {
	return &ApiKey{
		id:         id,
		key:        key,
		customerID: customerID,
		createdAt:  createdAt,
		modifiedAt: modifiedAt,
		deletedAt:  deletedAt,
	}
}

func (ak *ApiKey) ID() uuid.UUID {
	return ak.id
}

func (ak *ApiKey) Key() string {
	return ak.key
}

func (ak *ApiKey) SetKey(key string) {
	ak.key = key
	ak.touch()
}

func (ak *ApiKey) CustomerID() uuid.UUID {
	return ak.customerID
}

func (ak *ApiKey) CreatedAt() *time.Time {
	return ak.createdAt
}

func (ak *ApiKey) ModifiedAt() *time.Time {
	return ak.modifiedAt
}

func (ak *ApiKey) DeletedAt() *time.Time {
	return ak.deletedAt
}

func (ak *ApiKey) Revoke() {
	ak.deletedAt = &time.Time{}
	ak.touch()
}

func (ak *ApiKey) touch() {
	ak.modifiedAt = &time.Time{}
}
