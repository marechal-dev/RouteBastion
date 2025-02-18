CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE "limitation_kind" AS ENUM (
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

CREATE TABLE "clients" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (uuid_generate_v4()),
  "name" text NOT NULL,
  "api_key" text UNIQUE NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (now()),
  "modified_at" timestamp DEFAULT null,
  "deleted_at" timestamp DEFAULT null
);

CREATE TABLE "limitations" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (uuid_generate_v4()),
  "client_id" uuid NOT NULL,
  "kind" limitation_kind NOT NULL,
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
  "client_id" uuid NOT NULL,
  "selected_cloud_id" uuid NOT NULL,
  "status" optimization_status NOT NULL,
  "kind" request_kind NOT NULL,
  "started_at" timestamp DEFAULT null,
  "ended_at" timestamp DEFAULT null,
  "created_at" timestamp NOT NULL DEFAULT (now()),
  "modified_at" timestamp DEFAULT null
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

CREATE INDEX "idx_limitations_client_id" ON "limitations" ("client_id");

CREATE INDEX "idx_optimization_id" ON "optimization_waypoints" ("optimization_id");

CREATE INDEX "idx_optimizations_client_id" ON "optimizations" ("client_id");

CREATE INDEX "idx_optimizations_selected_cloud_id" ON "optimizations" ("selected_cloud_id");

CREATE INDEX "idx_provider_id" ON "provider_communication" ("provider_id");

CREATE INDEX "idx_provider_constraints_and_features_provider_id" ON "provider_constraints_and_features" ("provider_id");

ALTER TABLE "limitations" ADD FOREIGN KEY ("client_id") REFERENCES "clients" ("id");

ALTER TABLE "optimization_waypoints" ADD FOREIGN KEY ("optimization_id") REFERENCES "optimizations" ("id");

ALTER TABLE "optimizations" ADD FOREIGN KEY ("client_id") REFERENCES "clients" ("id");

ALTER TABLE "optimizations" ADD FOREIGN KEY ("selected_cloud_id") REFERENCES "providers" ("id");

ALTER TABLE "provider_communication" ADD FOREIGN KEY ("provider_id") REFERENCES "providers" ("id");

ALTER TABLE "provider_constraints_and_features" ADD FOREIGN KEY ("provider_id") REFERENCES "providers" ("id");
