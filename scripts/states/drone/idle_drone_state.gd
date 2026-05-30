extends State
class_name IdleDroneState
## Idle drone state
##
## State for drones resting and rotating slowly until a player enters detection range

@export var state_sprite : int = 0

@onready var drone_movement_component: DroneMovementComponent = $"../../Components/DroneMovementComponent"
@onready var engine_component: EngineComponent = $"../../Components/EngineComponent"

var player : Node
var _time_since_last_flash : float = 0.0
var _is_flashing : bool = false

func _ready() -> void:
	player = Helpers.player

func enter() -> void:
	if sprite:
		sprite.frame = state_sprite
	_is_flashing = false
	if engine_component:
		engine_component.stop()
	
	# Randomize initial timing offset so beeps are desynchronized
	var interval = 3.0
	if drone_movement_component:
		interval = drone_movement_component.idle_flash_interval
	_time_since_last_flash = randf_range(0.0, interval)

func update(delta: float) -> void:
	# Transition immediately to ChasingDroneState if damaged
	var health_component = object.get_node_or_null("Components/HealthComponent")
	if health_component and health_component.is_damaged:
		finished.emit(self, "ChasingDroneState")
		return

	if is_instance_valid(player):
		var distance_to_player : float = object.global_position.distance_to(player.global_position)
		if distance_to_player < drone_movement_component.detection_range:
			finished.emit(self, "ChasingDroneState")
			return

	# Idle beep and flash logic
	_time_since_last_flash += delta
	var interval = drone_movement_component.idle_flash_interval
	if _time_since_last_flash >= interval:
		# Reset tracking
		_time_since_last_flash = wrapf(_time_since_last_flash, 0, interval)
		_flash()

	if _is_flashing and _time_since_last_flash >= 0.2:
		_is_flashing = false
		if sprite:
			sprite.frame = state_sprite

func _flash() -> void:
	_is_flashing = true
	if sprite:
		sprite.frame = 1 # Flash to active frame (glowing eyes)
	var beep = object.get_node_or_null("BeepSound") as AudioStreamPlayer2D
	if beep:
		beep.play()

func physics_update(delta: float) -> void:
	# Rotate slowly
	object.angular_velocity = drone_movement_component.idle_rotation_speed
	# Dampen linear velocity to stay still
	object.linear_velocity = object.linear_velocity.lerp(Vector2.ZERO, 5.0 * delta)
