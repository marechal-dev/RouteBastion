package cryptography

import uuid "github.com/satori/go.uuid"

type UuidApiKeyGenerator struct {}

func NewUuidApiKeyGenerator() *UuidApiKeyGenerator {
	return &UuidApiKeyGenerator{}
}

func (u *UuidApiKeyGenerator) Generate() string {
	return uuid.NewV4().String()
}
