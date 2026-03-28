extends Node
class_name State
## template for a state
##
## a blueprint for states managed by the state machine

# signal used to exit this state and change a different one
signal finished

# reference to object on which the state machine is run on
@onready var object: Node = get_parent().get_parent() if get_parent() and get_parent().get_parent() else null
@onready var sprite: Sprite2D = object.get_node_or_null("Sprite2D") if object else null
@onready var collider = object.get_node_or_null("Collider") if object else null
@onready var player_camera: Camera2D = get_node_or_null("../../../Player/PlayerCamera")
@onready var ui: CanvasLayer = get_node_or_null("../../../Player/PlayerCamera/UI")
@onready var vhs_shader: CanvasLayer = get_node_or_null("../../../Player/PlayerCamera/VHSShader")
@onready var animation_player: AnimationPlayer = object.get_node_or_null("AnimationPlayer") if object else null

# handle initialization when entering this state
func enter() -> void:
	pass


# handle cleanup when exiting this state
func exit() -> void:
	pass


# receive engine _input delegation
func input() -> void:
	pass


# receive engine _process delegation
func update(_delta: float) -> void:
	pass


# receive engine _physics_process delegation
func physics_update(_delta: float) -> void:
	pass
