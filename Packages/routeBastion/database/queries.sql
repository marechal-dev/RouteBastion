-- name: CreateClient :one
INSERT INTO clients (
  id, name, api_key
) VALUES (
  $1, $2, $3
) RETURNING *;

-- name: GetClientByApiKey :one
SELECT c.id,
  c.name,
  c.api_key,
  c.created_at,
  c.modified_at,
  c.deleted_at
FROM clients AS c
WHERE c.api_key = $1 LIMIT 1;

-- name: InsertLimitation :one
INSERT INTO limitations (
  client_id, kind, value
) VALUES (
  $1, $2, $3
) RETURNING *;

-- name: GetLimitationsByClientID :many
SELECT l.id,
  l.client_id,
  l.kind,
  l.value,
  l.created_at,
  l.modified_at,
  l.deleted_at
FROM limitations AS l
WHERE l.client_id = $1 AND l.deleted_at IS NULL;

-- name: UpdateLimitationKindAndValue :exec
UPDATE limitations
  SET kind = $2,
    value = $3
WHERE limitations.id = $1;

-- name: UpdateLimitationValue :exec
UPDATE limitations
  SET value = $2
WHERE limitations.id = $1;

-- name: DeleteLimitation :exec
DELETE FROM limitations WHERE limitations.id = $1;

-- Name: CreateProvider :one
INSERT INTO providers (
  name
) VALUES (
  $1
) RETURNING *;

-- name: GetProviderDetailsByID :one
SELECT
	sqlc.embed(providers),
  sqlc.embed(provider_communication),
  sqlc.embed(provider_constraints_and_features)
FROM providers
  JOIN provider_communication ON providers.id = provider_communication.provider_id
  JOIN provider_constraints_and_features ON providers.id = provider_constraints_and_features.provider_id
WHERE providers.id = $1;

-- name: GetAvailableProviders :many
SELECT
  sqlc.embed(providers),
  sqlc.embed(provider_communication),
  sqlc.embed(provider_constraints_and_features)
FROM providers
  JOIN provider_communication ON providers.id = provider_communication.provider_id
  JOIN provider_constraints_and_features ON providers.id = provider_constraints_and_features.provider_id
WHERE providers.deleted_at IS NULL
ORDER BY providers.name ASC;

-- name: GetOptimizationHistoryByCustomerID :many
SELECT
  sqlc.embed(optimizations),
  sqlc.embed(optimization_waypoints)
FROM optimizations
  JOIN optimization_waypoints ON optimizations.id = optimization_waypoints.optimization_id
WHERE optimizations.client_id = $1
ORDER BY optimizations.created_at DESC;
