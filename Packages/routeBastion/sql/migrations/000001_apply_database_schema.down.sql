-- Drop all foreign key constraints
ALTER TABLE "vehicles" DROP CONSTRAINT IF EXISTS "vehicles_customer_id_fkey";
ALTER TABLE "provider_constraints_and_features" DROP CONSTRAINT IF EXISTS "provider_constraints_and_features_provider_id_fkey";
ALTER TABLE "provider_communication" DROP CONSTRAINT IF EXISTS "provider_communication_provider_id_fkey";
ALTER TABLE "optimization_vehicles" DROP CONSTRAINT IF EXISTS "optimization_vehicles_vehicle_id_fkey";
ALTER TABLE "optimization_vehicles" DROP CONSTRAINT IF EXISTS "optimization_vehicles_optimization_id_fkey";
ALTER TABLE "optimizations" DROP CONSTRAINT IF EXISTS "optimizations_selected_cloud_id_fkey";
ALTER TABLE "optimizations" DROP CONSTRAINT IF EXISTS "optimizations_customer_id_fkey";
ALTER TABLE "optimization_waypoints" DROP CONSTRAINT IF EXISTS "optimization_waypoints_optimization_id_fkey";
ALTER TABLE "constraints" DROP CONSTRAINT IF EXISTS "constraints_customer_id_fkey";
ALTER TABLE "api_keys" DROP CONSTRAINT IF EXISTS "api_keys_customer_id_fkey";

-- Drop all indexes
DROP INDEX IF EXISTS "idx_api_keys_customer_id_created_at_desc_active";
DROP INDEX IF EXISTS "idx_api_keys_customer_id";
DROP INDEX IF EXISTS "idx_constraints_customer_id";
DROP INDEX IF EXISTS "idx_constraints_active";
DROP INDEX IF EXISTS "idx_optimization_id";
DROP INDEX IF EXISTS "idx_optimizations_customer_id";
DROP INDEX IF EXISTS "idx_optimizations_selected_cloud_id";
DROP INDEX IF EXISTS "idx_optimizations_active";
DROP INDEX IF EXISTS "idx_optimization_vehicle_optimization_id";
DROP INDEX IF EXISTS "idx_optimization_vehicle_vehicle_id";
DROP INDEX IF EXISTS "idx_provider_communication_provider_id";
DROP INDEX IF EXISTS "idx_provider_constraints_and_features_provider_id";
DROP INDEX IF EXISTS "idx_providers_active";
DROP INDEX IF EXISTS "idx_vehicles_customer_id";

-- Drop all tables (reverse order of dependencies)
DROP TABLE IF EXISTS "vehicles";
DROP TABLE IF EXISTS "providers";
DROP TABLE IF EXISTS "provider_constraints_and_features";
DROP TABLE IF EXISTS "provider_communication";
DROP TABLE IF EXISTS "optimization_vehicles";
DROP TABLE IF EXISTS "optimizations";
DROP TABLE IF EXISTS "optimization_waypoints";
DROP TABLE IF EXISTS "constraints";
DROP TABLE IF EXISTS "api_keys";
DROP TABLE IF EXISTS "customers";

-- Drop all ENUM types
DROP TYPE IF EXISTS "cargo_kind";
DROP TYPE IF EXISTS "request_kind";
DROP TYPE IF EXISTS "communication_method";
DROP TYPE IF EXISTS "optimization_status";
DROP TYPE IF EXISTS "constraint_kind";

-- Drop extension
DROP EXTENSION IF EXISTS "uuid-ossp";
