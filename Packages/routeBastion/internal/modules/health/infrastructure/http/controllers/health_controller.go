package controllers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/platform/database"
)

type HealthController interface {
	Index(c *gin.Context)
}

type healthController struct {
	db database.DBProvider
}

func NewHealthController(db database.DBProvider) HealthController {
	return &healthController{
		db: db,
	}
}

func (h *healthController) Index(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"db": h.db.Health(),
	})
}
