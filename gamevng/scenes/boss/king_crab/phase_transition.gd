extends EnemyState

@export var transition_duration: float = 3.0
var dialog_started: bool = false
var previous_process_mode: Node.ProcessMode

func _enter():
	obj.velocity.x = 0
	obj.change_animation("angry")
	timer = transition_duration
	dialog_started = false
	
	# Store original process mode and set boss to process during pause
	previous_process_mode = obj.process_mode
	obj.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Lock player input and play dialog
	if GameManager.player:
		GameManager.player.velocity = Vector2.ZERO
		GameManager.player.lock_input(1000)
	
	# Set Dialogic autoload to process during pause (for input handling)
	Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect to dialog end signal before starting
	if not Dialogic.timeline_ended.is_connected(_on_dialog_ended):
		Dialogic.timeline_ended.connect(_on_dialog_ended)
	
	# Start the dialog
	var dialog_node = Dialogic.start("kingcrab_phase2")
	dialog_started = true
	
	# Set the dialog layout and all children to process during pause
	if dialog_node:
		_set_process_mode_recursive(dialog_node, Node.PROCESS_MODE_ALWAYS)
	
	# Freeze the game after dialog is setup
	get_tree().paused = true

func _exit():
	# Disconnect signal
	if Dialogic.timeline_ended.is_connected(_on_dialog_ended):
		Dialogic.timeline_ended.disconnect(_on_dialog_ended)
	
	# Restore Dialogic process mode
	Dialogic.process_mode = Node.PROCESS_MODE_INHERIT
	
	# Restore original process mode
	obj.process_mode = previous_process_mode
	
	# Unfreeze the game when exiting this state
	get_tree().paused = false
	
	# Unlock player input
	if GameManager.player:
		GameManager.player.unlock_input()

func _on_dialog_ended():
	# This will be called when dialog finishes, even during pause
	change_state(fsm.states.idle)

func _update(delta: float):
	# Fallback timer in case dialog doesn't start
	if not dialog_started and update_timer(delta):
		change_state(fsm.states.idle)

func _set_process_mode_recursive(node: Node, mode: Node.ProcessMode):
	node.process_mode = mode
	for child in node.get_children():
		_set_process_mode_recursive(child, mode)
