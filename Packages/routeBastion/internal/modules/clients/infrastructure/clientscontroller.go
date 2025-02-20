package infrastructure

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/clients/dtos"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/clients/infrastructure/presenters"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/clients/usecases"
)

type ClientsController interface {
	Create(c *gin.Context)
	GetOneByApiKey(c *gin.Context)
}

type clientsController struct {
	createClientUseCase usecases.CreateClientUseCase
}

func (cc *clientsController) Create(c *gin.Context) {
	dto := &dtos.CreateUserDTO{};

	err := c.BindJSON(&dto)

	if err != nil {
		c.JSON(http.StatusBadRequest, map[string]string{
			"error": "Invalid payload",
		})

		return
	}

	client := cc.createClientUseCase.Execute(dto)

	presenter := presenters.FromDomain(client)

	c.JSON(http.StatusCreated, presenter)
}

func (cc *clientsController) GetOneByApiKey(c *gin.Context) {
	c.JSON(http.StatusNoContent, map[string]string{
		"status": "in development",
	})
}
