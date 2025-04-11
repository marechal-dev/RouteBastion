CREATE TYPE "constraint_kind" AS ENUM (
  'budget',
  'availability',
  'performance',
  'security',
  'feature'
);

CREATE TYPE "optimization_status" AS ENUM (
  'enqueued',
  'running',
  'executed',
  'failed',
  'canceled'
);

CREATE TYPE "communication_method" AS ENUM (
  'rest',
  'protocol_buffers'
);

CREATE TYPE "request_kind" AS ENUM (
  'sync',
  'batch'
);

CREATE TYPE "cargo_kind" AS ENUM (
  'bulk_cargo',
  'containerized_cargo',
  'refrigerated_cargo',
  'dry_cargo',
  'alive_cargo',
  'dangerous_cargo',
  'fragile_cargo',
  'indivisible_and_exceptional_cargo',
  'vehicle_cargo'
);

CREATE TABLE "customers" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (uuid_generate_v4()),
  "name" text NOT NULL,
  "business_identifier" text UNIQUE NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (now()),
  "modified_at" timestamp DEFAULT null,
  "deleted_at" timestamp DEFAULT null
);

CREATE TABLE "api_keys" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (uuid_generate_v4()),
  "key" text UNIQUE NOT NULL,
  "customer_id" uuid NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (now()),
  "modified_at" timestamp DEFAULT null,
  "deleted_at" timestamp DEFAULT null
);

CREATE TABLE "constraints" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (uuid_generate_v4()),
  "customer_id" uuid NOT NULL,
  "kind" constraint_kind NOT NULL,
  "value" jsonb NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (now()),
  "modified_at" timestamp DEFAULT null,
  "deleted_at" timestamp DEFAULT null
);

CREATE TABLE "optimization_waypoints" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (uuid_generate_v4()),
  "optimization_id" uuid NOT NULL,
  "latitude" float8 NOT NULL,
  "longitude" float8 NOT NULL
);

CREATE TABLE "optimizations" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (uuid_generate_v4()),
  "customer_id" uuid NOT NULL,
  "selected_cloud_id" uuid NOT NULL,
  "status" optimization_status NOT NULL,
  "kind" request_kind NOT NULL,
  "cost" numeric(10,2) NOT NULL,
  "started_at" timestamp DEFAULT null,
  "ended_at" timestamp DEFAULT null,
  "created_at" timestamp NOT NULL DEFAULT (now()),
  "modified_at" timestamp DEFAULT null
);

CREATE TABLE "optimization_vehicles" (
  "optimization_id" uuid NOT NULL,
  "vehicle_id" uuid NOT NULL,
  PRIMARY KEY ("optimization_id", "vehicle_id")
);

CREATE TABLE "provider_communication" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (uuid_generate_v4()),
  "provider_id" uuid NOT NULL,
  "accessible_with" communication_method NOT NULL,
  "url" text UNIQUE NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (now()),
  "modified_at" timestamp DEFAULT null,
  "deleted_at" timestamp DEFAULT null
);

CREATE TABLE "provider_constraints_and_features" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (uuid_generate_v4()),
  "provider_id" uuid NOT NULL,
  "max_waypoints" integer NOT NULL,
  "supports_async_batch_requests" boolean NOT NULL
);

CREATE TABLE "providers" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (uuid_generate_v4()),
  "name" text NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (now()),
  "modified_at" timestamp DEFAULT null,
  "deleted_at" timestamp DEFAULT null
);

CREATE TABLE "vehicles" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (uuid_generate_v4()),
  "plate" text UNIQUE NOT NULL,
  "capacity" float8 NOT NULL,
  "cargo_type" cargo_kind NOT NULL,
  "customer_id" uuid NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (now()),
  "modified_at" timestamp DEFAULT null,
  "deleted_at" timestamp DEFAULT null
);

CREATE INDEX "idx_api_keys_customer_id" ON "api_keys" ("customer_id");

CREATE INDEX "idx_constraints_customer_id" ON "constraints" ("customer_id");

CREATE INDEX "idx_optimization_id" ON "optimization_waypoints" ("optimization_id");

CREATE INDEX "idx_optimizations_customer_id" ON "optimizations" ("customer_id");

CREATE INDEX "idx_optimizations_selected_cloud_id" ON "optimizations" ("selected_cloud_id");

CREATE INDEX "idx_optimization_vehicle_optimization_id" ON "optimization_vehicles" ("optimization_id");

CREATE INDEX "idx_optimization_vehicle_vehicle_id" ON "optimization_vehicles" ("vehicle_id");

CREATE INDEX "idx_provider_communication_provider_id" ON "provider_communication" ("provider_id");

CREATE INDEX "idx_provider_constraints_and_features_provider_id" ON "provider_constraints_and_features" ("provider_id");

CREATE INDEX "idx_vehicles_customer_id" ON "vehicles" ("customer_id");

CREATE INDEX "idx_constraints_active" ON "constraints" ("customer_id") WHERE deleted_at IS NULL;

CREATE INDEX "idx_providers_active" ON "providers" ("id") WHERE deleted_at IS NULL;

CREATE INDEX "idx_optimizations_active" ON "optimizations" ("customer_id") WHERE deleted_at IS NULL;

CREATE INDEX "idx_api_keys_customer_id_created_at_desc_active" ON "api_keys" ("customer_id", "created_at" DESC) WHERE deleted_at IS NULL;

ALTER TABLE "api_keys" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("id");

ALTER TABLE "constraints" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("id");

ALTER TABLE "optimization_waypoints" ADD FOREIGN KEY ("optimization_id") REFERENCES "optimizations" ("id");

ALTER TABLE "optimizations" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("id");

ALTER TABLE "optimizations" ADD FOREIGN KEY ("selected_cloud_id") REFERENCES "providers" ("id");

ALTER TABLE "optimization_vehicles" ADD FOREIGN KEY ("optimization_id") REFERENCES "optimizations" ("id");

ALTER TABLE "optimization_vehicles" ADD FOREIGN KEY ("vehicle_id") REFERENCES "vehicles" ("id");

ALTER TABLE "provider_communication" ADD FOREIGN KEY ("provider_id") REFERENCES "providers" ("id");

ALTER TABLE "provider_constraints_and_features" ADD FOREIGN KEY ("provider_id") REFERENCES "providers" ("id");

ALTER TABLE "vehicles" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("id");
