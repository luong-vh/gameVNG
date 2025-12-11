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
	if auto_find_buttons and button_nodes.is_empty():
		_find_buttons()
		
	#connect all button signals
	for button in button_nodes:
		if button and not button.button_pressed.is_connected(_on_button_pressed):
			button.button_pressed.connect(_on_button_pressed)
			
	print("[ButtonSequenceManager] Initialized with correct sequence: ", correct_sequence)
		
func _find_buttons() -> void:
	button_nodes.clear()
	for child in get_children():
		if child is PuzzleButton:
			button_nodes.append(child)
	print("[ButtonSequenceManager] Found ", button_nodes.size(), " buttons")	
		
func _on_button_pressed(button_color: String) -> void:
	if is_puzzle_complete or is_resetting:
		return
	
	print("[ButtonSequenceManager] Button pressed: ", button_color)		
	current_sequence.append(button_color)	
		
	if _is_sequence_correct_so_far():
		print("[ButtonSequenceManager] Correct so far! Progress: ", current_sequence.size(), "/", correct_sequence.size())
		sequence_progress.emit(current_sequence.size(), correct_sequence.size())
		
		#check if success
		if current_sequence.size() == correct_sequence.size():
			_on_puzzle_success()
	else: 
		print("[ButtonSequenceManager] Wrong sequence! Resetting...")
		_on_puzzle_failed()
	
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
	print("[ButtonSequenceManager] ✗ Wrong sequence, resetting...")
	
	# Emit reset signal
	puzzle_reset.emit()
	
	# Wait before resetting
	is_resetting = true
	await get_tree().create_timer(reset_delay).timeout
	
	# Reset all buttons
	reset_puzzle()
	is_resetting = false

func reset_puzzle() -> void:
	"""Reset the entire puzzle to initial state"""
	current_sequence.clear()
	is_puzzle_complete = false
	
	for button in button_nodes:
		if button:
			button.reset()
	
	print("[ButtonSequenceManager] Puzzle reset")
	
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
