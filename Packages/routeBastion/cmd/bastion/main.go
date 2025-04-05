package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os/signal"
	"syscall"
	"time"

	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/server"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/utils"
)

func gracefulShutdown(apiServer *http.Server, done chan bool) {
	// Create context that listens for the interrupt signal from the OS.
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	// Listen for the interrupt signal.
	<-ctx.Done()

	log.Println("shutting down gracefully, press Ctrl+C again to force")

	// The context is used to inform the server it has 5 seconds to finish
	// the request it is currently handling
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := apiServer.Shutdown(ctx); err != nil {
		log.Printf("Server forced to shutdown with error: %v", err)
	}

	log.Println("Server exiting")

	// Notify the main goroutine that the shutdown is complete
	done <- true
}

func main() {
	config, err := utils.LoadConfig(".")
	if err != nil {
		log.Fatalf("could not load config: %v", err)
	}

	tp, err := utils.InitTracer()
	if err != nil {
		log.Fatalf("failed to initialize tracer: %v", err)
	}

	defer func() {
		if err := tp.Shutdown(context.Background()); err != nil {
			log.Fatalf("failed to shut down tracer provider: %v", err)
		}
	}()

	mp, err := utils.InitMeter()
	if err != nil {
		log.Fatalf("failed to initialize meter: %v", err)
	}
	defer func() {
		if err := mp.Shutdown(context.Background()); err != nil {
			log.Fatalf("failed to shut down meter provider: %v", err)
		}
	}()

	server := server.NewServer(config)

	// Create a done channel to signal when the shutdown is complete
	done := make(chan bool, 1)

	// Run graceful shutdown in a separate goroutine
	go gracefulShutdown(server, done)

	serverErr := server.ListenAndServe()
	if serverErr != nil && serverErr != http.ErrServerClosed {
		panic(fmt.Sprintf("http server error: %s", serverErr))
	}

	// Wait for the graceful shutdown to complete
	<-done
	log.Println("Graceful shutdown complete.")
}
