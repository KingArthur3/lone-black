extends Logic
class_name SessionControlLogic
## Handles global gameplay input actions for the current session.

signal start_requested

@export var start_action := "thrust"


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
	elif event.is_action_pressed("fullscreen"):
		var mode := DisplayServer.window_get_mode()
		var is_window := mode != DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if is_window else DisplayServer.WINDOW_MODE_WINDOWED)
	elif event.is_action_pressed("restart"):
		var scene_path = get_tree().current_scene.scene_file_path
		get_tree().change_scene_to_file(scene_path)
	elif event.is_action_pressed(start_action):
		start_requested.emit()
