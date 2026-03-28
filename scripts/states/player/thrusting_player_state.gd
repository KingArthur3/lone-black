extends State
class_name ThrustingPlayerState
## Thrusting player state
##
## Player that is currently applying thrust to their ship

@onready var engine_component: EngineComponent = $"../../Components/EngineComponent"
@onready var shooting_component: ShootingComponent = $"../../Components/ShootingComponent"
@onready var player_movement_component: PlayerMovementComponent= $"../../Components/PlayerMovementComponent"


func enter() -> void:
	engine_component.start()
	

func exit() -> void:	
	engine_component.stop()


func physics_update(_delta: float) -> void:
	player_movement_component.rotate_towards_mouse()	
	player_movement_component.thrust_forward()
	player_movement_component.slow_down_if_needed()
	
	if Input.is_action_just_released("thrust"):
		finished.emit(self, "IdlePlayerState")
		
	if Input.is_action_pressed("shoot") and shooting_component.can_shoot:
		shooting_component.shoot()
