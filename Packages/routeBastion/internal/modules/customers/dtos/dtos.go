package dtos

type CreateCustomerDTO struct {
	Name string `json:"name" binding:"required"`
	BusinessIdentifier string `json:"businessIdentifier" binding:"required"`
}

type GetCustomerByApiKeyDTO struct {
	ApiKey string `json:"apiKey" binding:"required"`
}
