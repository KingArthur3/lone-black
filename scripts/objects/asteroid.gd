extends RigidBody2D

@export var min_scale := 0.5
@export var max_scale := 1.5
@export var base_mass := 1.0  # Mass at scale = 1.0

var variants: Array[String] = ["Variant1", "Variant2", "Variant3", "Variant4", "Variant5", "Variant6"]

func _ready() -> void:
	randomize()

	rotation_degrees = randi_range(1, 360)
	
	var scale_factor: float = randf_range(min_scale, max_scale)
	var custom_mass: float = base_mass * pow(scale_factor, 2)
	set_mass(custom_mass)

	var selected_index: int = randi() % variants.size()

	for i in range(variants.size()):
		var variant_name: String = variants[i]
		if not has_node(variant_name):
			continue

		var polygon := get_node(variant_name) as CollisionPolygon2D
		var sprite := polygon.get_node_or_null("Sprite2D")

		var is_selected: bool = (i == selected_index)

		polygon.disabled = not is_selected

		if is_selected:
			polygon.scale = Vector2.ONE * scale_factor
			if sprite:
				sprite.visible = true
		else:
			if sprite:
				sprite.visible = false
