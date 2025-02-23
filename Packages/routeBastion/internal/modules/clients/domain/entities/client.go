package entities

import (
	"time"

	uuid "github.com/satori/go.uuid"
)

type Client struct {
	id uuid.UUID
	name string
	apiKey string
	createdAt *time.Time
	modifiedAt *time.Time
	deletedAt *time.Time
}

func NewClient(
	name string,
	apiKey string,
) *Client {
	return &Client{
		id: uuid.NewV4(),
		name: name,
		apiKey: apiKey,
		createdAt: &time.Time{},
		modifiedAt: nil,
		deletedAt: nil,
	}
}

func NewClientFull(
	id uuid.UUID,
	name string,
	apiKey string,
	createdAt *time.Time,
	modifiedAt *time.Time,
	deletedAt *time.Time,
) *Client {
	return &Client{
		id: id,
		name: name,
		apiKey: apiKey,
		createdAt: createdAt,
		modifiedAt: modifiedAt,
		deletedAt: deletedAt,
	}
}

func (c *Client) ID() uuid.UUID {
	return c.id
}

func (c *Client) Name() string {
	return c.name
}

func (c *Client) SetName(name string) {
	c.name = name
	c.touch()
}

func (c *Client) ApiKey() string {
	return c.apiKey
}

func (c *Client) SetApiKey(apiKey string) {
	c.apiKey = apiKey
	c.touch()
}

func (c *Client) CreatedAt() *time.Time {
	return c.createdAt
}

func (c *Client) ModifiedAt() *time.Time {
	return c.modifiedAt
}

func (c *Client) DeletedAt() *time.Time {
	return c.deletedAt
}

func (c *Client) Disable() {
	c.deletedAt = &time.Time{}
	c.touch()
}

func (c *Client) IsDisabled() bool {
	if c.deletedAt == nil {
		return false
	}

	now := &time.Time{}
	nowUNIX := now.Unix()

	return c.deletedAt.Unix() > nowUNIX
}

func (c *Client) touch() {
	c.modifiedAt = &time.Time{}
}
