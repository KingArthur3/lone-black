extends State
class_name CatchUpDroneState
## Chasing drone state
##
## State for drones far from the player

@export var state_sprite : int

@onready var drone_movement_component: DroneMovementComponent = $"../../Components/DroneMovementComponent"
@onready var engine_component: EngineComponent = $"../../Components/EngineComponent"
var player : Node

func _ready() -> void:
	player = Helpers.player
	
	
func enter() -> void:
	sprite.frame = state_sprite
	if engine_component:
		engine_component.start()
	

func update(_delta: float) -> void:
	var health_component = object.get_node_or_null("Components/HealthComponent")
	if health_component and health_component.is_damaged:
		finished.emit(self, "ChasingDroneState")
		return

	if not is_instance_valid(player) or\
			object.global_position.distance_to(player.global_position) < drone_movement_component.wandering_distance:
		finished.emit(self, "WanderingDroneState")


func physics_update(_delta: float) -> void:
	if is_instance_valid(player):
		var distance_to_player : float = object.global_position.distance_to(player.global_position)
		var bonus_speed : float = (distance_to_player - drone_movement_component.wandering_distance) / 4
		
		drone_movement_component.thrust_towards_player(drone_movement_component.max_catch_up_speed + bonus_speed)
		drone_movement_component.slow_down_if_needed(drone_movement_component.max_catch_up_speed + bonus_speed)
	else:
		drone_movement_component.slow_down_if_needed(drone_movement_component.max_catch_up_speed)
	drone_movement_component.maintain_angular_velocity(drone_movement_component.desired_angular_velocity)
