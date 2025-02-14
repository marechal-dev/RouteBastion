package main

import (
	"context"
	"log"

	"github.com/gin-gonic/gin"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/util"
)

func main() {
	config, err := util.LoadConfig(".")
	if err != nil {
		log.Fatalf("could not load config: %v", err)
	}

	tp, err := util.InitTracer()
	if err != nil {
		log.Fatalf("failed to initialize tracer: %v", err)
	}

	defer func() {
		if err := tp.Shutdown(context.Background()); err != nil {
			log.Fatalf("Failed to shut down tracer provider: %v", err)
		}
	}()

	mp, err := util.InitMeter()
	if err != nil {
			log.Fatalf("Failed to initialize meter: %v", err)
	}
	defer func() {
			if err := mp.Shutdown(context.Background()); err != nil {
					log.Fatalf("Failed to shut down meter provider: %v", err)
			}
	}()

	r := gin.Default()

	r.GET("/ping", func(ctx *gin.Context) {
		ctx.JSON(200, gin.H{
			"message": "pong",
		})
	})

	r.Run(config.ServerAddress)
}
