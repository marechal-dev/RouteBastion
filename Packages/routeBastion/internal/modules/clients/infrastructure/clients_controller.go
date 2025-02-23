package infrastructure

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/database"
	usecases "github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/clients/application/use_cases"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/clients/dtos"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/clients/infrastructure/persistence"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/clients/infrastructure/presenters"
)

type ClientsController struct {
	queries *database.Queries
}

func NewClientsController(queries *database.Queries) ClientsController {
	return ClientsController{
		queries: queries,
	}
}

func (cc *ClientsController) Create(c *gin.Context) {
	dto := &dtos.CreateUserDTO{};

	err := c.BindJSON(&dto)

	if err != nil {
		c.JSON(http.StatusBadRequest, map[string]string{
			"error": "Invalid payload",
		})

		return
	}

	repository := persistence.NewPostgreSQLClientsRepository(cc.queries)
	useCase := usecases.NewCreateClientUseCase(repository)

	client := useCase.Execute(dto)

	payload := presenters.FromDomain(client)

	c.JSON(http.StatusCreated, payload)
}

func (cc *ClientsController) GetOneByApiKey(c *gin.Context) {
	apiKey := c.Param("apiKey")

	repository := persistence.NewPostgreSQLClientsRepository(cc.queries)
	useCase := usecases.NewGetOneClientUseCaseImpl(repository)

	foundClient := useCase.Execute(apiKey)

	if foundClient == nil {
		message := fmt.Sprintf("client for API key %s not found", apiKey)

		c.JSON(http.StatusNotFound, map[string]string{
			"error": message,
		})

		return
	}

	payload := presenters.FromDomain(foundClient)

	c.JSON(http.StatusOK, payload)
}
