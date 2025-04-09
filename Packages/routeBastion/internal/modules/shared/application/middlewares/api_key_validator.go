package middlewares

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/platform/database"
)

func ApiKeyValidatorMiddleware(db database.DBProvider) gin.HandlerFunc {
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

		// queries := db.GetQueries()

		// _, err := queries.GetCustomerByApiKey(ctx, apiKey)

		// if err != nil {
		// 	ctx.AbortWithStatusJSON(
		// 		http.StatusForbidden,
		// 		gin.H{
		// 			"error": "Invalid API key",
		// 		},
		// 	)

		// 	return
		// }

		ctx.Next()
	}
}
