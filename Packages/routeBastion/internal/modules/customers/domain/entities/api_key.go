package entities

import (
	"time"

	uuid "github.com/satori/go.uuid"
)

type ApiKey struct {
	id         uuid.UUID
	key        string
	createdAt  *time.Time
	modifiedAt *time.Time
	deletedAt  *time.Time
}

func NewApiKey(
	key string,
) *ApiKey {
	now := time.Now()
	return &ApiKey{
		id:         uuid.NewV4(),
		key:        key,
		createdAt:  &now,
		modifiedAt: nil,
		deletedAt:  nil,
	}
}

func RehydrateApiKey(
	id uuid.UUID,
	key string,
	createdAt *time.Time,
	modifiedAt *time.Time,
	deletedAt *time.Time,
) *ApiKey {
	return &ApiKey{
		id:         id,
		key:        key,
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
	now := time.Now()
	ak.deletedAt = &now
	ak.touch()
}

func (ak *ApiKey) touch() {
	now := time.Now()
	ak.modifiedAt = &now
}
