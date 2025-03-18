-- Drop Foreign Keys
ALTER TABLE "vehicles" DROP CONSTRAINT "vehicles_customer_id_fkey";
ALTER TABLE "provider_constraints_and_features" DROP CONSTRAINT "provider_constraints_and_features_provider_id_fkey";
ALTER TABLE "provider_communication" DROP CONSTRAINT "provider_communication_provider_id_fkey";
ALTER TABLE "optimization_vehicles" DROP CONSTRAINT "optimization_vehicles_vehicle_id_fkey";
ALTER TABLE "optimization_vehicles" DROP CONSTRAINT "optimization_vehicles_optimization_id_fkey";
ALTER TABLE "optimizations" DROP CONSTRAINT "optimizations_selected_cloud_id_fkey";
ALTER TABLE "optimizations" DROP CONSTRAINT "optimizations_customer_id_fkey";
ALTER TABLE "optimization_waypoints" DROP CONSTRAINT "optimization_waypoints_optimization_id_fkey";
ALTER TABLE "constraints" DROP CONSTRAINT "constraints_customer_id_fkey";

-- Drop Indexes
DROP INDEX IF EXISTS "idx_provider_constraints_and_features_provider_id";
DROP INDEX IF EXISTS "idx_provider_communication_provider_id";
DROP INDEX IF EXISTS "idx_optimization_vehicle_vehicle_id";
DROP INDEX IF EXISTS "idx_optimization_vehicle_optimization_id";
DROP INDEX IF EXISTS "idx_optimizations_selected_cloud_id";
DROP INDEX IF EXISTS "idx_optimizations_customer_id";
DROP INDEX IF EXISTS "idx_optimization_id";
DROP INDEX IF EXISTS "idx_constraints_customer_id";
DROP INDEX IF EXISTS "idx_constraints_active";
DROP INDEX IF EXISTS "idx_providers_active";
DROP INDEX IF EXISTS "idx_optimizations_active";

-- Drop Tables
DROP TABLE IF EXISTS "vehicles";
DROP TABLE IF EXISTS "providers";
DROP TABLE IF EXISTS "provider_constraints_and_features";
DROP TABLE IF EXISTS "provider_communication";
DROP TABLE IF EXISTS "optimization_vehicles";
DROP TABLE IF EXISTS "optimizations";
DROP TABLE IF EXISTS "optimization_waypoints";
DROP TABLE IF EXISTS "constraints";
DROP TABLE IF EXISTS "customers";

-- Drop Types
DROP TYPE IF EXISTS "cargo_kind";
DROP TYPE IF EXISTS "request_kind";
DROP TYPE IF EXISTS "communication_method";
DROP TYPE IF EXISTS "optimization_status";
DROP TYPE IF EXISTS "constraint_kind";

-- Drop Extension
DROP EXTENSION IF EXISTS "uuid-ossp";
