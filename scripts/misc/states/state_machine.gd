extends Node
class_name StateMachine
## universal state machine
##
## delegates engine callbacks to the current state and
## handles switching between states

@export var initial_state : State

var current_state : State
var states : Dictionary = {}

func _ready():
	# add all children states to the dictionary and connect their exit signals to the on_state_finished() function
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.finished.connect(on_state_finished)
			
	if initial_state:
		initial_state.enter()
		current_state = initial_state

# delegate _process engine callback to current state (also runs input loop of the state)
func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)
		current_state.input()


# delegate _physics_process engine callback to current state
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

# handle switching between states
func on_state_finished(_state: State, new_state_name):
	var new_state = states.get(new_state_name.to_lower()) # fetch new state node
	
	if not new_state:
		print("state not found!")
		return
	
	# allow the current state to clean up
	if current_state:
		current_state.exit()
	
	current_state = new_state
	
	# let the state initialize stuff
	new_state.enter()
