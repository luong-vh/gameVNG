extends Node2D

@export var respawn_player: bool = true
@export var respawn_delay: float = 0.4

@onready var player_hit_area = $PlayerHitArea2D
@onready var enemy_hit_area = $EnemyHitArea2D

func _ready() -> void:
	player_hit_area.hitted.connect(_on_hit_area_2d_hitted_player)
	enemy_hit_area.hitted.connect(_on_hit_area_2d_hitted_enemy)

func _on_hit_area_2d_hitted_player(area: Variant) -> void:
	if respawn_player && GameManager.player.health > 0:
		GUIManager.fade_to_black()
		await get_tree().create_timer(respawn_delay).timeout
		GameManager.respawn_at_ground_checkpoint()

func _on_hit_area_2d_hitted_enemy(area: Variant) -> void:
	pass
