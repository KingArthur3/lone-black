extends State
class_name WanderingDroneState
## Wandering drone state
##
## State for drones slowy creeping towards the player

@export var state_sprite : int

@onready var drone_movement_component: DroneMovementComponent = $"../../Components/DroneMovementComponent"
@onready var engine_component: EngineComponent = $"../../Components/EngineComponent"

var player : Node

func _ready() -> void:
	player = Helpers.player


func enter() -> void:
	sprite.frame = state_sprite


func update(_delta: float) -> void:
	if is_instance_valid(player):
		var distance_to_player : float = object.global_position.distance_to(player.global_position)
		
		if  distance_to_player < drone_movement_component.chase_distance:
			finished.emit(self, "ChasingDroneState")
		elif distance_to_player > drone_movement_component.wandering_distance + 10:
			finished.emit(self, "CatchUpDroneState")


func physics_update(_delta: float) -> void:
	if is_instance_valid(player):
		drone_movement_component.thrust_towards_player(drone_movement_component.max_speed)
	drone_movement_component.maintain_angular_velocity(drone_movement_component.desired_angular_velocity)
	drone_movement_component.slow_down_if_needed(drone_movement_component.max_speed)
