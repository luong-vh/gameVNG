extends BaseCollectible

@export var coin_amount: int = 1
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	super._ready() # Ensures the base class's _ready() is called, which connects interaction_available
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)

func _on_collect():
	# Ngắt kết nối tương tác để không nhặt được nữa (nếu cần)
	monitoring = false # Tắt theo dõi va chạm (nếu là Area2D)

	# In ra thông báo thu thập coin
	print("Đã thu thập " + str(coin_amount) + " coin!")
	
	# BẮT ĐẦU CHẠY ANIMATION
	animated_sprite_2d.play("collected")
	
# HÀM MỚI: Chỉ tự hủy khi animation CHẠY XONG
func _on_animation_finished():
	if animated_sprite_2d.animation == "collected":
		queue_free() # Tự hủy sau khi animation "collected" chạy xong
