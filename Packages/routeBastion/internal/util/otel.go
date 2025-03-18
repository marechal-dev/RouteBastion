package util

import (
	"context"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp/otlpmetric/otlpmetricgrpc"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
	"go.opentelemetry.io/otel/sdk/metric"
	"go.opentelemetry.io/otel/sdk/resource"
	"go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.17.0"
)

func InitTracer() (*trace.TracerProvider, error) {
	ctx := context.Background()

	res, err := resource.New(ctx,
		resource.WithAttributes(
				semconv.ServiceNameKey.String("RouteBastion-Broker-Tracing"),
		),
	)
	if err != nil {
			return nil, err
	}

	// Configure the OTLP trace exporter
	exp, err := otlptracegrpc.New(ctx,
			otlptracegrpc.WithInsecure(),
			otlptracegrpc.WithEndpoint("otel-collector:4317"),
	)
	if err != nil {
			return nil, err
	}

	// Create the TracerProvider with the exporter
	tp := trace.NewTracerProvider(
			trace.WithBatcher(exp),
			trace.WithResource(res),
	)

	// Set the global TracerProvider
	otel.SetTracerProvider(tp)

	return tp, nil
}

func InitMeter() (*metric.MeterProvider, error) {
	ctx := context.Background()

	res, err := resource.New(ctx,
		resource.WithAttributes(
				semconv.ServiceNameKey.String("RouteBastion-Broker-Measuring"),
		),
	)
	if err != nil {
			return nil, err
	}

	// Configure the OTLP metric exporter
	exp, err := otlpmetricgrpc.New(ctx,
			otlpmetricgrpc.WithInsecure(),
			otlpmetricgrpc.WithEndpoint("otel-collector:4317"),
	)
	if err != nil {
			return nil, err
	}

	// Create the MeterProvider with the exporter
	mp := metric.NewMeterProvider(
			metric.WithReader(metric.NewPeriodicReader(exp)),
			metric.WithResource(res),
	)

	// Set the global MeterProvider
	otel.SetMeterProvider(mp)

	return mp, nil
}
