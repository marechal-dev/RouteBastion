package entities

import (
	"time"

	uuid "github.com/satori/go.uuid"
)

type Provider struct {
	id uuid.UUID
	name string

	communicationMethods []*Communication
	constraintsAndFeatures *ConstraintAndFeature

	createdAt *time.Time
	modifiedAt *time.Time
	deletedAt *time.Time
}

func NewProvider(
	name string,
	constraintsAndFeatures *ConstraintAndFeature,
) *Provider {
	return &Provider{
		id: uuid.NewV4(),
		name: name,

		communicationMethods: []*Communication{},
		constraintsAndFeatures: constraintsAndFeatures,

		createdAt: &time.Time{},
		modifiedAt: nil,
		deletedAt: nil,
	}
}

func (p *Provider) ID() uuid.UUID {
	return p.id
}

func (p *Provider) Name() string {
	return p.name
}

func (p *Provider) CommunicationMethods() []*Communication {
	return p.communicationMethods
}

func (p *Provider) ConstraintsAndFeatures() *ConstraintAndFeature {
	return p.constraintsAndFeatures
}

func (p *Provider) CreatedAt() *time.Time {
	return p.createdAt
}

func (p *Provider) ModifiedAt() *time.Time {
	return p.modifiedAt
}

func (p *Provider) DeletedAt() *time.Time {
	return p.deletedAt
}

func (p *Provider) Disable() {
	p.deletedAt = &time.Time{}
	p.touch()
}

func (p *Provider) IsDisabled() bool {
	if p.deletedAt == nil {
		return false
	}

	now := &time.Time{}
	nowUNIX := now.Unix()

	return p.deletedAt.Unix() > nowUNIX
}

func (p *Provider) touch() {
	p.modifiedAt = &time.Time{}
}
