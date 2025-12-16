class_name PuzzleButton
extends Node2D

signal button_pressed(button_color: String)

enum ButtonColor {GREEN, RED, YELLOW}
@export var button_color: ButtonColor = ButtonColor.GREEN

enum ButtonState {IDLE, ACTIVATED, LOCKED}
var current_state : ButtonState = ButtonState.IDLE

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interactive_area: InteractiveArea2D = $InteractiveArea2D

var color_names: Dictionary = {
	ButtonColor.GREEN: "green", 
	ButtonColor.RED: "red",
	ButtonColor.YELLOW: "yellow"
}

func _ready() -> void:
	# Add to puzzle_buttons group for easy finding
	add_to_group("puzzle_buttons")
	
	#connect interaction signal
	if interactive_area:
		interactive_area.interacted.connect(_on_interacted)
		interactive_area.interaction_available.connect(_on_interaction_available)
		interactive_area.interaction_unavailable.connect(_on_interaction_unavailable)
	else:
		push_error("[PuzzleButton] No InteractiveArea2D found! Button won't work.")
	
	#set initial animation based on color
	_update_animation()
	
	print("[PuzzleButton] %s button ready at position %s" % [get_color_name(), global_position])

func _on_interacted() -> void:
	if current_state == ButtonState.LOCKED:
		return
	activate()
	
func activate() -> void:
	"""Activate the button and emit signal"""
	if current_state == ButtonState.ACTIVATED:
		print("[PuzzleButton] %s button already activated, ignoring" % get_color_name())
		return
	
	print("[PuzzleButton] %s button ACTIVATED!" % get_color_name())
	current_state = ButtonState.ACTIVATED
	_update_animation()

	button_pressed.emit(get_color_name())
	print("[PuzzleButton] Signal emitted for %s" % get_color_name())
	 
func reset() -> void:
	print("[PuzzleButton] Resetting %s button to IDLE" % get_color_name())
	current_state = ButtonState.IDLE
	_update_animation()
	
func lock() -> void:
	current_state = ButtonState.LOCKED
	_update_animation()	
	
func get_color_name() -> String:
	return color_names.get(button_color, "unknown")
	
func _update_animation() -> void:
	if not animated_sprite:
		return 
	
	var color_name = get_color_name()
	
	match current_state:
		ButtonState.IDLE:
			animated_sprite.play(color_name + "_idle")
		ButtonState.ACTIVATED:
			animated_sprite.play(color_name + "_activated")
		ButtonState.LOCKED:
			animated_sprite.play(color_name + "_locked")

func _on_interaction_available() -> void:
	if current_state != ButtonState.LOCKED and animated_sprite:
		animated_sprite.modulate = Color(1.2, 1.2, 1.2)  # Brighten

func _on_interaction_unavailable() -> void:
	if animated_sprite:
		animated_sprite.modulate = Color(1.0, 1.0, 1.0)  # Normal
