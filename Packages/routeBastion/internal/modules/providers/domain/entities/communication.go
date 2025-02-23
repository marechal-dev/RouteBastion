package entities

import (
	"time"

	uuid "github.com/satori/go.uuid"
)

type CommunicationMethod string

const (
	CommunicationMethodRest            CommunicationMethod = "rest"
	CommunicationMethodProtocolBuffers CommunicationMethod = "protocol_buffers"
)

type Communication struct {
	id uuid.UUID
	accessibleWith CommunicationMethod
	url string

	createdAt *time.Time
	modifiedAt *time.Time
	deletedAt *time.Time
}

func NewCommunication(
	accessibleWith CommunicationMethod,
	url string,
) *Communication {
	return &Communication{
		id: uuid.NewV4(),
		accessibleWith: accessibleWith,
		url: url,
		createdAt: &time.Time{},
		modifiedAt: nil,
		deletedAt: nil,
	}
}

func NewFullCommunication(
	id uuid.UUID,
	accessibleWith CommunicationMethod,
	url string,
	createdAt *time.Time,
	modifiedAt *time.Time,
	deletedAt *time.Time,
) *Communication {
	return &Communication{
		id: id,
		accessibleWith: accessibleWith,
		url: url,
		createdAt: createdAt,
		modifiedAt: modifiedAt,
		deletedAt: deletedAt,
	}
}

func (c *Communication) ID() uuid.UUID {
	return c.id
}

func (c *Communication) AccessibleWith() CommunicationMethod {
	return c.accessibleWith
}

func (c *Communication) URL() string {
	return c.url
}

func (c *Communication) CreatedAt() *time.Time {
	return c.createdAt
}

func (c *Communication) ModifiedAt() *time.Time {
	return c.modifiedAt
}

func (c *Communication) DeletedAt() *time.Time {
	return c.deletedAt
}

func (c *Communication) Disable() {
	c.deletedAt = &time.Time{}
	c.touch()
}

func (c *Communication) IsDisabled() bool {
	if c.deletedAt == nil {
		return false
	}

	now := &time.Time{}
	nowUNIX := now.Unix()

	return c.deletedAt.Unix() > nowUNIX
}

func (c *Communication) touch() {
	c.modifiedAt = &time.Time{}
}
