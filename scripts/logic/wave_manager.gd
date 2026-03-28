extends Logic
class_name WaveManager
## Manager of the wave system
##
## Initiates and keeps track of enemy waves

@export var waves : Array[PackedScene] = []
@export var break_time : float = 5

@onready var break_timer: Timer = $BreakTimer
@onready var next_wave_sound: AudioStreamPlayer = $NextWaveSound
@onready var wave_text : Label

var wave_number : int = -1
var wave_active := false

func _ready() -> void:
	break_timer.wait_time = break_time
	
	wave_text = Helpers.ui.get_node("WaveText")
	wave_text.visible = false
	
	start_waves()

func start_waves() -> void:
	break_timer.start()


func _start_wave() -> void:
	wave_number += 1

	if wave_number >= waves.size():
		print("No more waves to spawn.")
		return

	next_wave_sound.play()
	wave_text.text = "Wave " + str(wave_number + 1)
	wave_text.visible = true

	var wave_scene: PackedScene = waves[wave_number]
	var wave_instance: Node2D = wave_scene.instantiate()

	# Center wave on player
	var player_position = Helpers.player.global_position
	wave_instance.global_position = player_position

	# Add to Helpers.game instead of this node
	Helpers.game.add_child(wave_instance)

	wave_active = true


func _process(delta: float) -> void:
	if wave_active and not _any_drones_alive():
		break_timer.start()
		wave_text.visible = false
		wave_active = false


func _any_drones_alive() -> bool:
	for drone in Helpers.game.get_tree().get_nodes_in_group("drone"):
		if is_instance_valid(drone):
			return true
	return false
