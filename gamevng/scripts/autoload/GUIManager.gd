extends CanvasLayer

# 1. Định nghĩa các tín hiệu
signal fade_to_black_finished
signal fade_from_black_finished

@onready var _fade_animation_player = $FadeController/AnimationPlayer
@onready var _heart_container = $HeartsContainer

func _ready():
	# Kết nối signal nội bộ của AnimationPlayer
	# để biết khi nào nó chạy xong
	_fade_animation_player.animation_finished.connect(_on_animation_finished)

# 2. Các hàm để GameManager gọi
func fade_to_black():
	_fade_animation_player.play("fade_to_black")

func fade_from_black():
	_fade_animation_player.play("fade_from_black")

# 3. Hàm này lắng nghe AnimationPlayer
#    và phát tín hiệu của riêng nó ra ngoài
func _on_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		emit_signal("fade_to_black_finished")
	elif anim_name == "fade_from_black":
		emit_signal("fade_from_black_finished")

func set_max_heart_gui(max :int):
	if max > 10:
		print("wtf max health = %d??" %max)
		_heart_container.set_max_heart(5)
		return
	_heart_container.set_max_heart(max)

func update_heart_gui(health: int):
	if (health <=0): return
	var hearts = _heart_container.get_children()
	if hearts.size() == 0:
		return
	for i in range(health):
		if i >= hearts.size(): return
		hearts[i].update(true)
		
	for i in range(health,hearts.size()):
		hearts[i].update(false)
