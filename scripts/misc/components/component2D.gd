extends Node2D
class_name Component2D
## 2D component template
##
## blueprint for building components

# reference to the object which this component controls
@onready var object: Node = get_parent().get_parent() if get_parent() and get_parent().get_parent() else null
@onready var sprite: Sprite2D = object.get_node_or_null("Sprite2D") if object else null
@onready var collider = object.get_node_or_null("Collider") if object else null
@onready var player_camera: Camera2D = get_node_or_null("../../../Player/PlayerCamera")
@onready var ui: CanvasLayer = get_node_or_null("../../../Player/PlayerCamera/UI")
@onready var vhs_shader: CanvasLayer = get_node_or_null("../../../Player/PlayerCamera/VHSShader")

func handle_input() -> void:
	pass
