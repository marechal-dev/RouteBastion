package controllers

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/database"
	usecases "github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/application/use_cases"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/dtos"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/infrastructure/cryptography"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/infrastructure/persistence"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/infrastructure/presenters"
)

type CustomersController struct {
	db database.DatabaseService
}

func NewCustomersController(db database.DatabaseService) CustomersController {
	return CustomersController{
		db: db,
	}
}

func (cc *CustomersController) Create(c *gin.Context) {
	dto := &dtos.CreateCustomerDTO{};

	err := c.BindJSON(&dto)

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid payload",
		})

		return
	}

	repository := persistence.NewPostgreSQLCustomersRepository(cc.db)
	apiKeyGen := cryptography.NewUuidApiKeyGenerator()
	useCase := usecases.NewCreateCustomerUseCase(repository, apiKeyGen)

	customer := useCase.Execute(dto)

	payload := presenters.FromDomain(customer)

	c.JSON(http.StatusCreated, payload)
}

func (cc *CustomersController) GetOneByApiKey(c *gin.Context) {
	apiKey := c.Param("apiKey")

	repository := persistence.NewPostgreSQLCustomersRepository(cc.db)
	useCase := usecases.NewGetOneCustomerUseCaseImpl(repository)

	foundCustomer := useCase.Execute(apiKey)

	if foundCustomer == nil {
		message := fmt.Sprintf("customer for API key %s not found", apiKey)

		c.JSON(http.StatusNotFound, map[string]string{
			"error": message,
		})

		return
	}

	payload := presenters.FromDomain(foundCustomer)

	c.JSON(http.StatusOK, payload)
}
