extends Component
class_name CollisionManagerComponent
## Collision manager
##
## Manages collisions of this object to, for example, apply damage
## to this object

@export var bullet_damage: int = 0
@export var drone_damage: int = 0
@export var player_damage: int = 0

@onready var health_component: HealthComponent = $"../HealthComponent"

var invincible : bool = false:
	set(new_invincible):
		invincible = new_invincible
		if new_invincible and object.is_connected("body_entered", manage_collision):
			object.disconnect("body_entered", manage_collision)
		elif not object.is_connected("body_entered", manage_collision):
			object.connect("body_entered", manage_collision)

func _ready() -> void:
	object.connect("body_entered", manage_collision)
	unstuck()


func manage_collision(body: Node) -> void:
	if not is_instance_valid(body):
		return


	if body is Bullet and bullet_damage > 0:
		health_component.damage(bullet_damage)
	elif body is Drone and drone_damage > 0:
		health_component.damage(drone_damage)
	elif body is Player and player_damage > 0:
		health_component.damage(player_damage)


func unstuck() -> void:
	if not object is Node2D:
		return

	var space_state = object.get_world_2d().direct_space_state
	var original_position = object.global_position

	var collision_node = object.get_node_or_null("Collider")
	if collision_node == null:
		collision_node = object.get_node_or_null("CollisionShape2D")

	var shape: Shape2D = null
	if collision_node is CollisionShape2D:
		shape = collision_node.shape
	elif collision_node is CollisionPolygon2D:
		# Polygon colliders do not expose a Shape2D for intersect_shape().
		# Skip unstuck for this case to avoid invalid queries.
		return

	if shape == null:
		return

	var max_attempts := 36
	var radius_step := 16.0
	var max_radius := 128.0

	for radius in range(0, int(max_radius), int(radius_step)):
		for i in max_attempts:
			var angle = (TAU / max_attempts) * i
			var offset = Vector2(cos(angle), sin(angle)) * radius
			var test_position = original_position + offset
			var query := PhysicsShapeQueryParameters2D.new()
			query.shape = shape
			query.transform = Transform2D(0, test_position)
			query.margin = 0.1
			query.collide_with_bodies = true
			query.collide_with_areas = true
			if object is CollisionObject2D:
				query.collision_mask = object.collision_mask

			var result = space_state.intersect_shape(query)

			if result.is_empty():
				object.global_position = test_position
				return

	print("Unstuck failed: no free space found.")
