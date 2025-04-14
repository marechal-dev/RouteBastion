-- name: CreateCustomer :one
INSERT INTO customers (
  id, name, business_identifier
) VALUES (
  $1, $2, $3
) RETURNING *;

-- name: GetOneCustomerByBusinessIdentifier :one
SELECT
  sqlc.embed(c),
  sqlc.embed(ak)
FROM customers AS c
JOIN api_keys AS ak
  ON c.id = ak.customer_id
WHERE c.business_identifier = $1
LIMIT 1;

-- name: GetCustomerByApiKey :one
SELECT
  sqlc.embed(c),
  sqlc.embed(ak)
FROM customers AS c
JOIN api_keys AS ak
  ON c.id = ak.customer_id
WHERE ak.key = $1
LIMIT 1;

-- name: DisableCustomer :exec
UPDATE customers
  SET deleted_at = $2
WHERE customers.id = $1;

-- name: CreateApiKey :one
INSERT INTO api_keys (
  id, key, customer_id, created_at
) VALUES (
  $1, $2, $3, $4
) RETURNING *;

-- name: DeleteApiKey :exec
UPDATE api_keys
SET
	modified_at = $2,
	deleted_at = $3
WHERE id = $1;

-- name: UpdateApiKey :exec
UPDATE api_keys
SET
	key = $2,
	modified_at = $3
WHERE id = $1;

-- name: GetApiKeyByCustomerID :one
SELECT
  ak.id,
  ak.key,
  ak.customer_id,
  ak.created_at,
  ak.modified_at,
  ak.deleted_at
FROM api_keys AS ak
WHERE (ak.customer_id, ak.deleted_at) = ($1, NULL)
ORDER BY ak.created_at DESC
LIMIT 1;

-- name: CreateVehicle :one
INSERT INTO vehicles (
  id,
  plate,
  capacity,
  cargo_type,
  customer_id,
  created_at
) VALUES (
  $1, $2, $3, $4, $5, $6
) RETURNING *;

-- name: GetManyVehiclesByCustomerID :many
SELECT
  v.id,
  v.plate,
  v.capacity,
  v.cargo_type,
  v.customer_id,
  v.created_at,
  v.modified_at,
  v.deleted_at
FROM vehicles AS v
WHERE (v.customer_id, v.deleted_at) = ($1, NULL);

-- name: DeleteVehicle :exec
UPDATE vehicles
  SET deleted_at = $2
WHERE vehicles.id = $1;

-- name: InsertConstraint :one
INSERT INTO constraints (
  customer_id, kind, value
) VALUES (
  $1, $2, $3
) RETURNING *;

-- name: GetConstraintsByCustomerID :many
SELECT
  c.id,
  c.customer_id,
  c.kind,
  c.value,
  c.created_at,
  c.modified_at,
  c.deleted_at
FROM constraints AS c
WHERE (c.customer_id, c.deleted_at) = ($1, NULL);

-- name: UpdateConstraintKindAndValue :exec
UPDATE constraints
  SET kind = $2,
    value = $3
WHERE constraints.id = $1;

-- name: UpdateConstraintValue :exec
UPDATE constraints
  SET value = $2
WHERE constraints.id = $1;

-- name: DeleteConstraint :exec
UPDATE constraints
  SET deleted_at = $2
WHERE constraints.id = $1;

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

-- name: GetActiveOptimizationsByCustomerID :many
SELECT
  sqlc.embed(optimizations),
  sqlc.embed(optimization_waypoints),
  sqlc.embed(optimization_vehicles)
FROM optimizations
  INNER JOIN optimization_waypoints ON optimizations.id = optimization_waypoints.optimization_id
  INNER JOIN optimization_vehicles ON optimizations.id = optimization_vehicles.optimization_id
WHERE (optimizations.customer_id, optimizations.ended_at) = ($1, NULL)
ORDER BY optimizations.created_at DESC;

-- name: GetOptimizationHistoryByCustomerID :many
SELECT
  sqlc.embed(optimizations),
  sqlc.embed(optimization_waypoints),
  sqlc.embed(optimization_vehicles)
FROM optimizations
  INNER JOIN optimization_waypoints ON optimizations.id = optimization_waypoints.optimization_id
  INNER JOIN optimization_vehicles ON optimizations.id = optimization_vehicles.optimization_id
WHERE optimizations.customer_id = $1
ORDER BY optimizations.created_at DESC;
