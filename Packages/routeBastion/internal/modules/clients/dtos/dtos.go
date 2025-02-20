package dtos

type CreateUserDTO struct {
	Name string `json:"name" binding:"required"`
}

type GetClientByApiKeyDTO struct {
	ApiKey string `json:"apiKey" binding:"required"`
}
