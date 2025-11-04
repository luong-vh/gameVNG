# pushable.gd - ATTACHED TO PLAYER
extends Node
class_name Pushable

@export_category("Push Settings")
@export var push_speed_multiplier: float = 0.7  # Player chậm lại
@export var stick_distance: float = 2.0  # Khoảng cách dính với player

var parent_body: RigidBody2D
var raycast_right: RayCast2D
var raycast_left: RayCast2D

# State
var is_being_pushed: bool = false
var pushing_player: CharacterBody2D = null
var push_direction: float = 0.0

func _ready():
	parent_body = get_parent() as RigidBody2D
	if not parent_body:
		return
		
	parent_body.add_to_group("pushable")

	
func _physics_process(delta):
	if not parent_body:
		return
		
	# Khóa rotation
	

func push(direction: float, player: CharacterBody2D = null) -> void:
	if not parent_body:
		return
	
	is_being_pushed = true
	push_direction = direction
	pushing_player = player

func stop_pushing() -> void:
	is_being_pushed = false
	pushing_player = null

func move_with_player() -> void:
	if not pushing_player:
		return
	
	# LẤY TỐC ĐỘ CỦA PLAYER
	var player_velocity = pushing_player.velocity.x
	
	# THÙNG ĐI THEO CHÍNH XÁC
	parent_body.linear_velocity.x = player_velocity
	
	# Giữ khoảng cách với player
	var distance_to_player = parent_body.global_position.x - pushing_player.global_position.x
	var expected_distance = push_direction * stick_distance
	
	# Điều chỉnh vị trí nếu cách xa quá
	if abs(distance_to_player - expected_distance) > 5.0:
		var correction = (expected_distance - distance_to_player) * 0.5
		parent_body.global_position.x += correction

func can_push_in_direction(direction: float) -> bool:
	var raycast = raycast_right if direction > 0 else raycast_left
	if not raycast:
		return true
		
	raycast.force_raycast_update()
	return not raycast.is_colliding()
	

	
