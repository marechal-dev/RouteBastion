package cryptography

type ApiKeyGenerator interface {
	Generate() string
}
