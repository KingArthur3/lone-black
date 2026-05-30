extends RigidBody2D
class_name Bullet
## Bullet
##
## Manages the explosion of the bullet and its homing behavior.

@export_group("Homing Configuration")
# The range (in pixels) within which the bullet can detect and seek enemies.
@export var detection_range : float = 200.0
# How fast the bullet can turn towards the target (in degrees per second).
@export var turn_rate : float = 60.0
# The cone of detection in front of the bullet (in degrees). e.g. 90 means 45 degrees to each side.
@export var detection_fov : float = 90.0

@export_group("Visuals & Effects")
@export var explosion_scene : PackedScene

# Keep reference to movement component if needed for compatibility
@onready var movement_component = $"Components/BulletMovementComponent"

var _initial_speed : float = 0.0
var _initialized_speed := false

func _ready() -> void:
	# Ensure the bullet starts with an aligned rotation
	if linear_velocity.length() > 0.0:
		rotation = linear_velocity.angle()


func get_closest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("drone")
	var closest_distance = INF
	var closest_enemy = null
	
	var forward_dir = linear_velocity.normalized()
	if forward_dir == Vector2.ZERO:
		forward_dir = Vector2.RIGHT.rotated(rotation)
		
	var half_fov_rad = deg_to_rad(detection_fov / 2.0)
	
	for enemy in enemies:
		if is_instance_valid(enemy):
			var to_enemy = enemy.global_position - global_position
			var distance = to_enemy.length()
			if distance > 0.0 and distance < detection_range and distance < closest_distance:
				var angle_diff = abs(forward_dir.angle_to(to_enemy / distance))
				if angle_diff <= half_fov_rad:
					closest_distance = distance
					closest_enemy = enemy
	return closest_enemy 


func _physics_process(delta: float) -> void:
	if not _initialized_speed:
		_initial_speed = linear_velocity.length()
		if _initial_speed > 0.0:
			_initialized_speed = true

	var closest_enemy = get_closest_enemy()
	if closest_enemy:
		# Homing logic: steer velocity towards target
		var target_dir = (closest_enemy.global_position - global_position).normalized()
		var current_dir = linear_velocity.normalized()
		
		# Fallback if velocity is zero
		if current_dir == Vector2.ZERO:
			current_dir = Vector2.RIGHT.rotated(rotation)
			
		var angle_to_target = current_dir.angle_to(target_dir)
		var max_turn_angle = deg_to_rad(turn_rate) * delta
		var new_dir = current_dir.rotated(clamp(angle_to_target, -max_turn_angle, max_turn_angle))
		
		# Apply velocity and align rotation
		var speed = _initial_speed if _initial_speed > 0.0 else 200.0
		linear_velocity = new_dir * speed
		rotation = linear_velocity.angle()
	else:
		# If no enemy, fly straight and align rotation with velocity
		if linear_velocity.length() > 0.0:
			rotation = linear_velocity.angle()
			if _initial_speed > 0.0:
				linear_velocity = linear_velocity.normalized() * _initial_speed


func explode() -> void:
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	get_tree().current_scene.add_child(explosion)	


func _on_despawn_timer_timeout() -> void:
	explode()
	queue_free()


func _on_body_entered(_body: Node) -> void:
	explode()
	queue_free()


func _on_body_exited(_body: Node) -> void:
	pass
