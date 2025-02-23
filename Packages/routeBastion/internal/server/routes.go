package server

import (
	"net/http"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func (s *Server) RegisterRoutes() http.Handler {
	r := gin.Default()

	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"},
		AllowHeaders:     []string{"Accept", "Content-Type", "X-API-Key"},
		AllowCredentials: true,
	}))

	// Health-check
	r.GET("/health", s.healthController.Index)

	// Clients
	clients := r.Group("/clients")
	{
		clients.GET("/:apiKey", s.clientsController.GetOneByApiKey)
		clients.POST("/", s.clientsController.Create)
	}

	return r
}
