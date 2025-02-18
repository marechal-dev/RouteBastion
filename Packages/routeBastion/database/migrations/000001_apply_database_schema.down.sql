-- Drop foreign key constraints
ALTER TABLE "limitations" DROP CONSTRAINT IF EXISTS "limitations_client_id_fkey";
ALTER TABLE "optimization_waypoints" DROP CONSTRAINT IF EXISTS "optimization_waypoints_optimization_id_fkey";
ALTER TABLE "optimizations" DROP CONSTRAINT IF EXISTS "optimizations_client_id_fkey";
ALTER TABLE "optimizations" DROP CONSTRAINT IF EXISTS "optimizations_selected_cloud_id_fkey";
ALTER TABLE "provider_communication" DROP CONSTRAINT IF EXISTS "provider_communication_provider_id_fkey";
ALTER TABLE "provider_constraints_and_features" DROP CONSTRAINT IF EXISTS "provider_constraints_and_features_provider_id_fkey";

-- Drop indexes
DROP INDEX IF EXISTS "idx_limitations_client_id";
DROP INDEX IF EXISTS "idx_optimization_id";
DROP INDEX IF EXISTS "idx_optimizations_client_id";
DROP INDEX IF EXISTS "idx_optimizations_selected_cloud_id";
DROP INDEX IF EXISTS "idx_provider_id";
DROP INDEX IF EXISTS "idx_provider_constraints_and_features_provider_id";

-- Drop tables
DROP TABLE IF EXISTS "provider_constraints_and_features";
DROP TABLE IF EXISTS "provider_communication";
DROP TABLE IF EXISTS "optimization_waypoints";
DROP TABLE IF EXISTS "optimizations";
DROP TABLE IF EXISTS "limitations";
DROP TABLE IF EXISTS "clients";
DROP TABLE IF EXISTS "providers";

-- Drop types
DROP TYPE IF EXISTS "limitation_kind";
DROP TYPE IF EXISTS "optimization_status";
DROP TYPE IF EXISTS "communication_method";
DROP TYPE IF EXISTS "request_kind";

-- Drop extension
DROP EXTENSION IF EXISTS "uuid-ossp";
