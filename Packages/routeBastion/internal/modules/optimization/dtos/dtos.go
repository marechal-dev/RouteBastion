package dtos

type WaypointDTO struct {
	Lat  float64 `json:"lat"  binding:"required"`
	Long float64 `json:"long" binding:"required"`
}

type VehicleDTO struct {
	ID        string  `json:"id"        binding:"required"`
	StartLat  float64 `json:"startLat"  binding:"required"`
	StartLong float64 `json:"startLong" binding:"required"`
	EndLat    float64 `json:"endLat"    binding:"required"`
	EndLong   float64 `json:"endLong"   binding:"required"`
}

type OptimizationRequestDTO struct {
	Pickups    []WaypointDTO `json:"pickups"    binding:"required"`
	Deliveries []WaypointDTO `json:"deliveries" binding:"required"`
	Vehicles   []VehicleDTO  `json:"vehicles"   binding:"required"`
}
