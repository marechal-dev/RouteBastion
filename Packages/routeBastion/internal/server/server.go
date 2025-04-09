package server

import (
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
	"github.com/go-playground/validator/v10"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"go.opentelemetry.io/contrib/instrumentation/github.com/gin-gonic/gin/otelgin"

	infraDB "github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/infrastructure/database"
	customers "github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/customers/infrastructure/http/controllers"
	health "github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/health/infrastructure/http/controllers"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/shared/application/middlewares"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/modules/shared/application/validators"
	platformDB "github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/platform/database"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/utils"
)

type Server struct {
	port int

	db platformDB.DBProvider

	healthController    health.HealthController
	customersController customers.CustomersController
}

func NewServer(config utils.AppEnvConfig) *http.Server {
	port, _ := strconv.Atoi(config.ServerPort)

	provider := infraDB.NewPgxProvider(
		config.DBDatabase,
		config.DBPassword,
		config.DBUsername,
		config.DBPort,
		config.DBHost,
		config.DBSchema,
	)

	newServer := &Server{
		port: port,
		db:   provider,
	}

	newServer.RegisterCustomValidators()
	newServer.RegisterControllers()

	// Declare Server config
	server := &http.Server{
		Addr:         fmt.Sprintf(":%d", newServer.port),
		Handler:      newServer.RegisterRoutes(),
		IdleTimeout:  time.Minute,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 30 * time.Second,
	}

	return server
}

func (s *Server) RegisterCustomValidators() {
	if v, ok := binding.Validator.Engine().(*validator.Validate); ok {
		v.RegisterValidation("cargoKind", validators.IsValidCargoKind)
	}
}

func (s *Server) RegisterControllers() {
	s.healthController = health.NewHealthController(s.db)
	s.customersController = customers.NewCustomersController(s.db)
}

func (s *Server) RegisterRoutes() http.Handler {
	r := gin.Default()

	r.Use(otelgin.Middleware("RouteBastion-Broker-HTTP"))

	r.Use(cors.New(cors.Config{
		AllowAllOrigins:  true,
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"},
		AllowHeaders:     []string{"Accept", "Content-Type", "RouteBastion-API-Key"},
		AllowCredentials: false,
	}))

	// Health-check
	r.GET("/health", s.healthController.Index)

	// Prometheus Metrics
	r.GET("/metrics", gin.WrapH(promhttp.Handler()))

	// Customers
	customers := r.Group("/customers")
	{
		customers.GET(
			"/:apiKey",
			middlewares.ApiKeyValidatorMiddleware(s.db),
			s.customersController.GetOneByApiKey,
		)
		customers.POST("/", s.customersController.Create)
	}

	return r
}
