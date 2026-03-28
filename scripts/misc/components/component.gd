extends Node
class_name Component
## component template
##
## blueprint for building components

# reference to the object which this component controls
@onready var object: Node = get_parent().get_parent() if get_parent() and get_parent().get_parent() else null
@onready var sprite: Sprite2D = object.get_node_or_null("Sprite2D") if object else null
@onready var collider = object.get_node_or_null("Collider") if object else null

func handle_input() -> void:
	pass
