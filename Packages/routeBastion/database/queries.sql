-- name: GetClientByApiKey :one
SELECT c.id,
  c.name,
  c.created_at,
  c.modified_at,
  c.deleted_at
FROM clients AS c
WHERE c.api_key = $1 LIMIT 1;
