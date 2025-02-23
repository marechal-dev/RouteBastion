package entities

import uuid "github.com/satori/go.uuid"

type ConstraintAndFeature struct {
	id uuid.UUID
	maxWaypoints int
	supportsAsyncBatchRequests bool
}

func NewConstraintAndFeature(
	maxWaypoints int,
	supportsAsyncBatchRequests bool,
) *ConstraintAndFeature {
	return &ConstraintAndFeature{
		id: uuid.NewV4(),
		maxWaypoints: maxWaypoints,
		supportsAsyncBatchRequests: supportsAsyncBatchRequests,
	}
}

func (cf *ConstraintAndFeature) ID() uuid.UUID {
	return cf.id
}

func (cf *ConstraintAndFeature) MaxWaypoints() int {
	return cf.maxWaypoints
}

func (cf *ConstraintAndFeature) SupportsAsyncBatchRequests() bool {
	return cf.supportsAsyncBatchRequests
}
