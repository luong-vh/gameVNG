extends CanvasLayer

# 1. Định nghĩa các tín hiệu
signal fade_to_black_finished
signal fade_from_black_finished

@onready var animation_player = $AnimationPlayer

func _ready():
	# Kết nối signal nội bộ của AnimationPlayer
	# để biết khi nào nó chạy xong
	animation_player.animation_finished.connect(_on_animation_finished)

# 2. Các hàm để GameManager gọi
func fade_to_black():
	animation_player.play("fade_to_black")

func fade_from_black():
	animation_player.play("fade_from_black")

# 3. Hàm này lắng nghe AnimationPlayer
#    và phát tín hiệu của riêng nó ra ngoài
func _on_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		emit_signal("fade_to_black_finished")
	elif anim_name == "fade_from_black":
		emit_signal("fade_from_black_finished")
