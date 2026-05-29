extends Node2D
class_name GameManager
## Root game orchestration.
##
## Coordinates high-level flow while delegating systems to logic nodes.

@export var player: NodePath

@onready var info_text: Label = $"Player/PlayerCamera/UI/InfoText"
@onready var asteroid_field_logic = $"logic/AsteroidFieldLogic"
@onready var session_control_logic = $"logic/SessionControlLogic"
@onready var wave_manager = $"logic/WaveManager"

var player_node: Node2D
var game_started := false

func _ready() -> void:
	player_node = get_node_or_null(player) as Node2D
	if session_control_logic:
		session_control_logic.start_requested.connect(_on_start_requested)


func _process(_delta: float) -> void:
	if not is_instance_valid(player_node):
		if info_text and not info_text.visible:
			info_text.text = "Press R to restart"
			info_text.visible = true
		return

	if asteroid_field_logic:
		asteroid_field_logic.update_field(player_node.global_position)


func _on_start_requested() -> void:
	if not game_started:
		start_game()


func start_game() -> void:
	game_started = true
	if info_text:
		info_text.visible = false
	if wave_manager:
		wave_manager.start_waves()


func restart_game() -> void:
	var scene_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file(scene_path)
