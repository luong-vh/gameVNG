extends EnemyCharacter


@onready var glow_light: Light2D = $GlowLight
@export var patrol_distance: float = 50.0
@export var pause_time: float = 1.0

func _ready() -> void:
	fsm = FSM.new(self , $States , $States/Run)
	type = "MUSHROOM"
	glow_light.visible = false
	super._ready()

func _add_into_enemy_manager():
	EnemyManager.add_enemy(self , type)

func _delete_from_enemy_manager():
	EnemyManager.remove_enemy(self , type)

func change_to_day_behavior():
	if glow_light:
		glow_light.visible = false
	self.scale = Vector2(1, 1)


func change_to_night_behavior():
	if glow_light:
		glow_light.visible = true
		glow_light.energy = 0.8
	self.scale = Vector2(1.5 , 1.5)
