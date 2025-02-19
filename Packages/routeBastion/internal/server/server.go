package server

import (
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/database"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/module/health"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/util"
)

type Server struct {
	port int

	db database.Service
	queries *database.Queries

	healthController health.HealthController
}

func NewServer(config util.AppEnvConfig) *http.Server {
	port, _ := strconv.Atoi(config.ServerPort)

	dbService := database.NewDatabaseService(
		config.DBDatabase,
		config.DBPassword,
		config.DBUsername,
		config.DBPort,
		config.DBHost,
		config.DBSchema,
	)

	dbQueries := database.New(dbService.GetConn())

	newServer := &Server{
		port: port,

		db: dbService,
		queries: dbQueries,
	}

	newServer.RegisterControllers()

	// Declare Server config
	server := &http.Server{
		Addr:         fmt.Sprintf(":%d", newServer.port),
		Handler:      newServer.RegisterRoutes(),
		IdleTimeout:  time.Minute,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 30 * time.Second,
	}

	return server
}

func (s *Server) RegisterControllers() {
	s.healthController = health.NewHealthController(s.db)
}
