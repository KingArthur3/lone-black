extends State
class_name ChasingDroneState
## Chasing drone state
##
## State for drones chasing the player

@export var state_sprite : int
@export var blinking_sprite : int
@export var blinking_interval : float

@onready var drone_movement_component: DroneMovementComponent = $"../../Components/DroneMovementComponent"
@onready var engine_component: EngineComponent = $"../../Components/EngineComponent"
@onready var blinking_timer: Timer = $"BlinkingTimer"

var player : Node

func _ready() -> void:
	player = Helpers.player
	blinking_timer.wait_time = blinking_interval


func _on_blinking_timer_timeout() -> void:
	if sprite.frame == state_sprite:
		sprite.frame = blinking_sprite
	else:
		sprite.frame = state_sprite


func enter() -> void:
	sprite.frame = state_sprite
	blinking_timer.start()
	

func exit() -> void:
	blinking_timer.stop()


func update(_delta: float) -> void:
	var health_component = object.get_node_or_null("Components/HealthComponent")
	if health_component and health_component.is_damaged:
		return

	if not is_instance_valid(player) or\
			object.global_position.distance_to(player.global_position) > drone_movement_component.chase_distance:
		finished.emit(self, "WanderingDroneState")


func physics_update(_delta: float) -> void:
	if is_instance_valid(player):
		drone_movement_component.thrust_towards_player(drone_movement_component.max_chase_speed)
	drone_movement_component.maintain_angular_velocity(drone_movement_component.desired_chase_angular_velocity)
	drone_movement_component.slow_down_if_needed(drone_movement_component.max_chase_speed)
