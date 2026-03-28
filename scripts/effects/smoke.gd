extends CPUParticles2D

@export var particle_texture : Texture2D
@export var size : float = 1

func _ready() -> void:
	texture = particle_texture
	
	amount *= size
	scale_amount_min *= size / 2
	scale_amount_max *= size / 2
	initial_velocity_min *= size
	initial_velocity_max *= size
	
	emitting = true


func _on_finished() -> void:
	queue_free()
