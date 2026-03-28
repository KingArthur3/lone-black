## player camera
##
## Makes the camera follow the parent of this script.
## The camera is slightly offset to the position of
## the mouse cursor, and supports screen shake. The
## scroll wheel also adjusts zoom level

extends Camera2D

@export var max_camera_offset: float = 150		# maximum allowed camera offset
@export var camera_lerp_speed: float = 1
@export var camera_offset_modifier: float = 2	# higher value = less offset
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0
@export var zoom_step: float = 0.1

@onready var parent: Node2D = $".."

var follow_offset := Vector2.ZERO
var shake_offset := Vector2.ZERO

func _process(delta: float) -> void:
	if parent:
		update_camera_offset(delta)

	apply_camera_shake(delta)
	offset = follow_offset + shake_offset


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			update_zoom(-zoom_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			update_zoom(zoom_step)


func update_zoom(delta_zoom: float) -> void:
	var new_zoom = zoom.x + delta_zoom
	new_zoom = clamp(new_zoom, min_zoom, max_zoom)
	zoom = Vector2(new_zoom, new_zoom)


# Reparenting logic
func _reparent(new_parent, node, old_transform):
	node.get_parent().remove_child(node)
	new_parent.add_child(node)
	node.transform = new_parent.get_global_transform().inverse() * old_transform

func change_parent(new_parent):
	call_deferred("_reparent", new_parent, self, get_global_transform())

func free_from_parent() -> void:
	var root = get_tree().root.get_node("Game")
	change_parent(root)
	parent = null

# Calculates offset from mouse cursor to apply smooth follow
func update_camera_offset(delta: float) -> void:
	var to_mouse = get_global_mouse_position() - global_position
	var distance = to_mouse.length() / camera_offset_modifier
	var clamped_distance = min(distance, max_camera_offset)
	var target_offset = to_mouse.normalized() * clamped_distance

	# Smooth follow offset
	follow_offset = follow_offset.lerp(target_offset, camera_lerp_speed * delta)

# Shake system
var shake_time_left := 0.0
var shake_intensity := 0.0
var rng := RandomNumberGenerator.new()

func shake_camera(duration_ms: int, intensity: float) -> void:
	shake_time_left = float(duration_ms) / 1000.0
	shake_intensity = intensity
	rng.randomize()

func apply_camera_shake(delta: float) -> void:
	if shake_time_left > 0.0:
		shake_time_left -= delta
		shake_offset = Vector2(
			rng.randf_range(-1.0, 1.0),
			rng.randf_range(-1.0, 1.0)
		) * shake_intensity
	else:
		shake_offset = Vector2.ZERO
