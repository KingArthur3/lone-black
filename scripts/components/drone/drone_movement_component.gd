extends Component
class_name DroneMovementComponent
## Drone movement component
##
## Makes this object move like a drone - homing
## towards the player with chase functionality

@export var forward_thrust: float = 100
@export var desired_angular_velocity: float = 10
@export var desired_chase_angular_velocity: float = 30
@export var torque: float = 10
@export var max_speed : float = 100
@export var max_chase_speed : float = 250
@export var max_catch_up_speed : float = 200
@export var wandering_distance : float = 300
@export var chase_distance : float = 120
@export var detection_range : float = 250.0
@export var idle_rotation_speed : float = 1.0
@export var idle_flash_interval : float = 3.0


var player : Node

func _ready() -> void:
	player = Helpers.player


func thrust_towards_player(speed : float) -> void:
	var to_player = player.global_position - object.global_position
	var desired_velocity = to_player.normalized() * speed
	
	var steering = desired_velocity - object.linear_velocity
	
	var max_force = forward_thrust
	if steering.length() > max_force:
		steering = steering.normalized() * max_force
	
	object.apply_central_force(steering)
	

func maintain_angular_velocity(speed : float) -> void:
	var chosen_angular_velocity = speed
	
	if object.angular_velocity < chosen_angular_velocity:
		object.apply_torque(torque)


func slow_down_if_needed(allowed_speed : float) -> void:	
	if object.linear_velocity.length() > allowed_speed:
		var damping_force = object.linear_velocity.normalized() * -forward_thrust * 0.3
		object.apply_central_force(damping_force)
