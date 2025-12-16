class_name ButtonManager
extends Node2D

#signal
signal puzzle_success
signal puzzle_reset
signal sequence_progress(current_step: int, total_steps: int)

#win sequence
@export var correct_sequence: Array[String] = ["green", "red", "yellow"]

#ref
@export var button_nodes: Array[PuzzleButton] = []

@export var auto_find_buttons: bool = true

@export var reset_delay: float = 1.0

@export var lock_on_success: bool = true

var current_sequence: Array[String] = []
var is_puzzle_complete: bool = false
var is_resetting: bool = false

func _ready() -> void:
	# Wait one frame for all buttons to be ready and add themselves to groups
	await get_tree().process_frame
	
	if auto_find_buttons and button_nodes.is_empty():
		_find_buttons()
		
	#connect all button signals
	for button in button_nodes:
		if button and not button.button_pressed.is_connected(_on_button_pressed):
			button.button_pressed.connect(_on_button_pressed)
			print("[ButtonManager] Connected to %s button" % button.get_color_name())
		else:
			push_warning("[ButtonManager] Button is null or already connected!")
			
	print("[ButtonManager] Initialized with correct sequence: ", correct_sequence)
	print("[ButtonManager] Buttons registered: ", button_nodes.size())
	
	if button_nodes.size() == 0:
		push_error("[ButtonManager] NO BUTTONS FOUND! Make sure buttons have PuzzleButton script attached!")
		
func _find_buttons() -> void:
	button_nodes.clear()
	# First check direct children
	for child in get_children():
		if child is PuzzleButton:
			button_nodes.append(child)
	# If no buttons found as children, search in the scene tree
	if button_nodes.is_empty():
		var buttons = get_tree().get_nodes_in_group("puzzle_buttons")
		for button in buttons:
			if button is PuzzleButton:
				button_nodes.append(button)
	print("[ButtonSequenceManager] Found ", button_nodes.size(), " buttons")	
		
func _on_button_pressed(button_color: String) -> void:
	if is_puzzle_complete or is_resetting:
		print("[ButtonManager] Ignoring press - puzzle complete or resetting")
		return
	
	print("[ButtonManager] ========================================")
	print("[ButtonManager] Button pressed: ", button_color)
	print("[ButtonManager] Current sequence before: ", current_sequence)
	print("[ButtonManager] Expected sequence: ", correct_sequence)		
	current_sequence.append(button_color)
	print("[ButtonManager] Current sequence after: ", current_sequence)	
		
	if _is_sequence_correct_so_far():
		print("[ButtonManager] ✓ CORRECT so far! Progress: ", current_sequence.size(), "/", correct_sequence.size())
		sequence_progress.emit(current_sequence.size(), correct_sequence.size())
		
		# Visual feedback - flash button green
		_flash_button_correct(button_color)
		
		#check if success
		if current_sequence.size() == correct_sequence.size():
			_on_puzzle_success()
	else: 
		print("[ButtonManager] ✗ WRONG sequence! Resetting...")
		
		# Visual feedback - flash all buttons red
		_flash_buttons_wrong()
		
		_on_puzzle_failed()

func _flash_button_correct(button_color: String) -> void:
	"""Flash the correct button green"""
	for button in button_nodes:
		if button and button.get_color_name() == button_color:
			var sprite = button.get_node_or_null("AnimatedSprite2D")
			if sprite:
				sprite.modulate = Color(0.5, 2.0, 0.5)  # Green flash
				await get_tree().create_timer(0.2).timeout
				sprite.modulate = Color(1.0, 1.0, 1.0)

func _flash_buttons_wrong() -> void:
	"""Flash all buttons red to indicate wrong sequence"""
	for button in button_nodes:
		if button:
			var sprite = button.get_node_or_null("AnimatedSprite2D")
			if sprite:
				sprite.modulate = Color(2.0, 0.5, 0.5)  # Red flash
	
	await get_tree().create_timer(0.3).timeout
	
	for button in button_nodes:
		if button:
			var sprite = button.get_node_or_null("AnimatedSprite2D")
			if sprite:
				sprite.modulate = Color(1.0, 1.0, 1.0)  # Back to normal
	
func _is_sequence_correct_so_far() -> bool:
	"""check if current sequence matches correct sequence up to current step"""
	if current_sequence.size() > correct_sequence.size():
		return false
	
	for i in range(current_sequence.size()):
		if current_sequence[i] != correct_sequence[i]:
			return false
	
	return true

func _on_puzzle_success() -> void:
	"""called when puzzle is solved correctly"""
	print("[ButtonSequenceManager] ✓ PUZZLE SOLVED!")
	is_puzzle_complete = true
	
	#lock all buttons
	if lock_on_success:
		for button in button_nodes:
			if button:
				button.lock()
	
	puzzle_success.emit()
	
func _on_puzzle_failed() -> void:
	print("[ButtonManager] ✗ Wrong sequence, resetting in %.1f seconds..." % reset_delay)
	
	# Emit reset signal
	puzzle_reset.emit()
	
	# Wait before resetting
	is_resetting = true
	print("[ButtonManager] Waiting for reset delay...")
	await get_tree().create_timer(reset_delay).timeout
	
	# Reset all buttons
	print("[ButtonManager] Calling reset_puzzle()...")
	reset_puzzle()
	is_resetting = false
	print("[ButtonManager] Reset complete! Ready for new attempt.")

func reset_puzzle() -> void:
	"""Reset the entire puzzle to initial state"""
	print("[ButtonManager] Resetting puzzle...")
	print("[ButtonManager] Clearing sequence: ", current_sequence)
	current_sequence.clear()
	is_puzzle_complete = false
	
	print("[ButtonManager] Resetting %d buttons..." % button_nodes.size())
	for button in button_nodes:
		if button:
			button.reset()
		else:
			push_warning("[ButtonManager] Found null button in button_nodes!")
	
	print("[ButtonManager] Puzzle reset complete!")
	
func set_sequence(new_sequence: Array[String]) -> void:
	"""Dynamically change the correct sequence"""
	correct_sequence = new_sequence
	reset_puzzle()
	print("[ButtonSequenceManager] New sequence set: ", correct_sequence)
	
##manual puzzle reset 
func manual_reset() -> void:
	reset_puzzle()

##check if puzzle is currently active
func is_active() -> bool:
	return not is_puzzle_complete and not is_resetting
