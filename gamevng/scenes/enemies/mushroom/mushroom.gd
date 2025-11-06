extends EnemyCharacter
const type = "MUSHROOM"

@onready var glow_light: Light2D = $GlowLight


func _ready() -> void:
	fsm = FSM.new(self , $States , $States/Run)
	_add_into_enemy_manager()
	glow_light.visible = false
	super._ready()

func _add_into_enemy_manager():
	EnemyManager.add_enemy(self , type)

func _delete_from_enemy_manager():
	EnemyManager.remove_enemy(self , type)

func change_to_day_behavior():
	print("[%s] Changed behavior to DAY" %self)
	if glow_light:
		glow_light.visible = false
	self.scale = Vector2(1, 1)


func change_to_night_behavior():
	print("[%s] Changed behavior to NIGHT" % self)
	if glow_light:
		glow_light.visible = true
		glow_light.energy = 0.8
	self.scale = Vector2(1.5 , 1.5)
