extends BaseCollectible

@export var coin_amount: int = 1
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Set này TRƯỚC khi gọi super._ready() để đảm bảo được apply
	show_when_collected = true
	collected_alpha = 0.4  # Độ mờ 40%

	super._ready()
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)

# Override set_state để đảm bảo coin play animation đúng khi restore
func set_state(state: Dictionary) -> void:
	super.set_state(state)

	if not animated_sprite_2d:
		return

	# Reset animation về đúng trạng thái
	if collected and visible:
		# Coin đã collected và hiển thị mờ - play animation default
		if animated_sprite_2d.sprite_frames.has_animation("default"):
			animated_sprite_2d.play("default")
		# IMPORTANT: Set modulate của AnimatedSprite2D để sync với parent
		animated_sprite_2d.modulate.a = modulate.a
	elif not collected:
		# Coin chưa collected - đảm bảo play animation default (không phải collected)
		if animated_sprite_2d.sprite_frames.has_animation("default"):
			animated_sprite_2d.play("default")
		# Đảm bảo coin không mờ khi chưa collected
		animated_sprite_2d.modulate.a = 1.0

func _on_collect():
	# Kiểm tra xem đây là lần đầu thu thập hay đã thu thập rồi
	if not collected:
		# Lần đầu thu thập - cộng coin vào inventory
		collected = true
		GameManager.inventory_system.add_coin(coin_amount)
	else:
		# Đã thu thập rồi (coin mờ) - chỉ biến mất, KHÔNG cộng coin
		pass

	# Play animation và sound cho cả 2 trường hợp
	AudioManager.play_sound("coin")
	animated_sprite_2d.play("collected")

func _on_animation_finished():
	# Sau animation, ẩn coin
	if animated_sprite_2d.animation == "collected":
		visible = false
		monitoring = false
