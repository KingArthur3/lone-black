extends Component
class_name TorqueMovementComponent
## Shared torque-based movement component for RigidBody2D actors.

@export var turn_thrust : float = 200
@export var max_turn_speed : float = 100
@export var forward_thrust : float = 100
@export var max_speed : float = 100


func rotate_towards_position(target_position: Vector2) -> void:
	var to_target_vector = target_position - object.global_position
	var desired_angle = to_target_vector.angle()
	_rotate_towards_angle(desired_angle)


func rotate_towards_mouse() -> void:
	rotate_towards_position(object.get_global_mouse_position())


func stop_turning() -> void:
	object.angular_velocity = 0


func thrust_forward(thrust : float = forward_thrust) -> void:
	var direction = Vector2.RIGHT.rotated(object.rotation)
	var force = direction * thrust
	object.apply_central_force(force)


func slow_down_if_needed(allowed_speed : float = max_speed, damping_thrust : float = forward_thrust) -> void:
	if object.linear_velocity.length() > allowed_speed:
		var damping_force = object.linear_velocity.normalized() * -damping_thrust * 1.2
		object.apply_central_force(damping_force)


func _rotate_towards_angle(desired_angle: float) -> void:
	var angle_diff = wrapf(desired_angle - object.rotation, -PI, PI)
	var desired_angular_velocity = angle_diff * 5 if max_turn_speed > abs(angle_diff) * 5 else max_turn_speed * sign(angle_diff)

	var torque : float = 0
	if (angle_diff > 0 and object.angular_velocity < desired_angular_velocity) or \
			(angle_diff < 0 and object.angular_velocity < desired_angular_velocity):
		torque = turn_thrust
	elif (angle_diff < 0 and object.angular_velocity > desired_angular_velocity) or \
			(angle_diff > 0 and object.angular_velocity > desired_angular_velocity):
		torque = -turn_thrust

	object.apply_torque(torque)
