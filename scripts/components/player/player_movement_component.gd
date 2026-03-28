extends TorqueMovementComponent
class_name PlayerMovementComponent
## Player movement module
##
## Turns the ship towards the mouse pointer and
## allows forward thrust to be applied.

@export var boost_thrust : float = 250		# Thrust applied when boosting
@export var boost_max_speed : float = 150
@export var boost_icon_path : NodePath
@export var boost_duration : float = 1
@export var boost_reload_time : float = 2
@export var boost_double_click_interval : float = 0.3

@onready var boost_icon : TextureRect = get_node(boost_icon_path)
@onready var boost_reload_timer : Timer = $"BoostReloadTimer"
@onready var boost_duration_timer : Timer = $"BoostDurationTimer"
@onready var boost_double_click_interval_timer : Timer = $"BoostDoubleClickInterval"
@onready var boost_ready_sound: AudioStreamPlayer = $"BoostReadySound"

var can_boost : bool = false

func _ready() -> void:
	boost_reload_timer.wait_time = boost_reload_time
	boost_duration_timer.wait_time = boost_duration
	boost_double_click_interval_timer.wait_time = boost_double_click_interval


func _on_boost_reload_timer_timeout() -> void:
	can_boost = true
	if boost_icon:
		boost_icon.visible = true
	boost_ready_sound.play()
	

func thrust_forward_with_boost() -> void:
	thrust_forward(boost_thrust)


func slow_down_boost_if_needed() -> void:	
	slow_down_if_needed(boost_max_speed, boost_thrust)
