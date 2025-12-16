extends Node2D


@export_file("*.tscn") var target_stage = ""
@export var target_door = "Door"
@onready var spawn_marker: Marker2D = $SpawnMarker2D
var spawn_position: Vector2

func _ready() -> void:
	if spawn_marker:
		spawn_position = spawn_marker.global_position
	else:
		spawn_position = global_position

func play_opening_anim():
	$AnimatedSprite2D.play("opening")

func play_closing_anim():
	$AnimatedSprite2D.play("closing")

func load_next_stage():
	play_closing_anim()
	# load next stage with target door name
	GameManager.change_stage(target_stage, target_door)

func _on_interactive_area_2d_interacted() -> void:
	load_next_stage()

func _on_interactive_area_2d_interaction_available() -> void:
	play_opening_anim()

func _on_interactive_area_2d_interaction_unavailable() -> void:
	play_closing_anim()
