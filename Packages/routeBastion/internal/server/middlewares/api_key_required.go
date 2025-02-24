package middlewares

import (
	"context"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/database"
)

func ApiKeyRequired(
	db database.Service,
) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		const apiKeyHeader string = "RouteBastion-API-Key"

		apiKey := ctx.GetHeader(apiKeyHeader)

		if apiKey == "" {
			ctx.AbortWithStatusJSON(
				http.StatusUnauthorized,
				gin.H{
					"error": "API Key header is missing",
				},
			)

			return
		}

		queries := database.New(db.GetConn())

		_, err := queries.GetClientByApiKey(context.Background(), apiKey)

		if err != nil {
			ctx.AbortWithStatusJSON(
				http.StatusForbidden,
				gin.H{
					"error": "Invalid API key",
				},
			)

			return
		}

		ctx.Next()
	}
}
