extends RigidBody2D
class_name Bullet
## Bullet
##
## Manages the explosion of the bullet upon hitting something

@export var max_homing_distance : float = 100
@export var explosion_scene : PackedScene

@onready var movement_component = $"Components/BulletMovementComponent"

func get_closest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("drone")
	var closest_distance = INF
	var closest_enemy = null
	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	return closest_enemy if closest_distance < max_homing_distance else null 


func _physics_process(_delta) -> void:
	var closest_enemy = get_closest_enemy()
	if closest_enemy:
		movement_component.rotate_towards_position(closest_enemy.global_position)
	else:
		movement_component.stop_turning()
	movement_component.thrust_forward()
	movement_component.slow_down_if_needed()


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
