class_name MagnetDecorator
extends PowerupDecorator

## Decorator for attracting collectibles to the player.

const MAGNET_RADIUS = 150.0
const MAGNET_FORCE = 200.0

func _init(target_player: Player, decorator_data: PowerupDecoratorData):
	super(target_player, decorator_data)
	pass

# Override the update method to add magnet logic
func update(delta: float) -> bool:
	# Call super.update() to handle duration and chain updates
	var expired = super.update(delta)
	if expired:
		return true

	# Get all collectibles in the scene
	var collectibles = player.get_tree().get_nodes_in_group("collectibles")
	
	for collectible in collectibles:
		# Ensure the collectible is a valid Node2D and not queued for deletion
		if not is_instance_valid(collectible) or not collectible is Node2D:
			continue
			
		# Don't attract the power-up that granted this magnet effect
		if collectible.get("data") != null and collectible.data.id == self.data.id:
			continue
			
		# Check if the collectible is attractable
		if collectible.get("is_attractable") == false:
			continue

		var distance_to_player = player.global_position.distance_to(collectible.global_position)
		
		if distance_to_player < MAGNET_RADIUS:
			# Calculate direction and move the collectible towards the player
			var direction = (player.global_position - collectible.global_position).normalized()
			collectible.global_position += direction * MAGNET_FORCE * delta
			
	return false
