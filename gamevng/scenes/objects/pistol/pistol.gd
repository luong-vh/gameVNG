extends AnimatableBody2D
class_name Pistol

@onready var horizontal_bar: ColorRect = $HorizontalBar
@onready var vertical_bar: ColorRect = $VerticalBar
@onready var detection_area: Area2D = $DetectionArea


@export_group("Push Settings")
@export var push_force: float = 600.0
@export_enum("Up", "Down", "Custom Angle") var push_direction: int = 0  ## 0=Up, 1=Down, 2=Custom
@export_range(0.0, 360.0, 1.0, "degrees") var push_angle: float = 90.0  ## Chỉ dùng khi push_direction = Custom Angle
@export var lock_input_duration: float = 0.5

@export_group("Trigger Condition")
@export_enum("Always", "Falling Only", "Rising Only") var trigger_condition: int = 1  ## 0=Always, 1=Falling (y>=0), 2=Rising (y<0)  

@export_group("Animation Settings")
@export var push_up_distance: float = 45.0  

var fsm: FSM = null
var original_offset_top: float = 0.0
var original_offset_bottom: float = 0.0

func _ready() -> void:
	vertical_bar.visible = false
	original_offset_top = horizontal_bar.offset_top
	original_offset_bottom = horizontal_bar.offset_bottom
	fsm = FSM.new(self, $States , $States/Idle )

func _process(delta: float) -> void:
	if fsm != null:
		fsm._update(delta)

func push_player(player) -> void:
	var push_vector: Vector2

	match push_direction:
		0:  ## Up
			push_vector = Vector2(0, -push_force)
		1:  ## Down
			push_vector = Vector2(0, push_force)
		2:  ## Custom Angle
			var angle_rad = deg_to_rad(push_angle)
			push_vector = Vector2(cos(angle_rad), -sin(angle_rad)) * push_force

	if player.has_method("lock_input"):
		player.lock_input(lock_input_duration)

	if player.has_method("apply_external_force"):
		player.apply_external_force(push_vector)
	elif player is CharacterBody2D:
		player.velocity = push_vector

func show_extended() -> void:
	vertical_bar.visible = true
	horizontal_bar.offset_top = original_offset_top - push_up_distance
	horizontal_bar.offset_bottom = original_offset_bottom - push_up_distance

func show_idle() -> void:
	horizontal_bar.offset_top = original_offset_top
	horizontal_bar.offset_bottom = original_offset_bottom
	vertical_bar.visible = false

func _on_detection_area_body_entered(body: Node2D) -> void:
	if fsm and fsm.current_state and fsm.current_state.has_method("_on_player_entered"):
		fsm.current_state._on_player_entered(body)
