class_name FishFactory
extends Node2D

# Improved Fish Factory using Factory Method Pattern with proper weighted rarity selection

# Base Fish Factory - Factory Method Pattern
class BaseFishFactory extends RefCounted:
	func create_fish(data: FishData) -> Fish:
		# Template method - subclasses can override specific steps
		var fish = _instantiate_fish()
		_configure_fish(fish, data)
		_apply_fish_behavior(fish, data)
		return fish

	func _instantiate_fish() -> Fish:
		# Override in subclasses for different fish types
		return preload("res://Entities/Fish/Fish.tscn").instantiate()

	func _configure_fish(fish: Fish, data: FishData) -> void:
		fish.fish_data = data
		if fish.has_node("Sprite2D"):
			fish.get_node("Sprite2D").texture = data.sprite_texture

	func _apply_fish_behavior(fish: Fish, data: FishData) -> void:
		# Base behavior - can be overridden
		fish.velocity = Vector2(1, 0) * data.get_effective_speed()

# Concrete Factories for different fish types
class CommonFishFactory extends BaseFishFactory:
	func _apply_fish_behavior(fish: Fish, data: FishData) -> void:
		super(fish, data)
		# Common fish have normal behavior
		fish.velocity *= 1.0

class RareFishFactory extends BaseFishFactory:
	func _apply_fish_behavior(fish: Fish, data: FishData) -> void:
		super(fish, data)
		# Rare fish move in patterns and faster
		fish.velocity *= 1.2

class LegendaryFishFactory extends BaseFishFactory:
	func _instantiate_fish() -> Fish:
		# Legendary fish could use a different scene with special effects
		# For now, fallback to regular fish scene
		var fish = preload("res://Entities/Fish/Fish.tscn").instantiate()
		return fish

	func _apply_fish_behavior(fish: Fish, data: FishData) -> void:
		super(fish, data)
		# Legendary fish have special abilities and faster speed
		fish.velocity *= 1.5

# Main Factory Properties
@export var fish_scene : PackedScene
@export var fish_data_list : Array[FishData]
@export var spawn_interval: float = 2.0

# Factory instances
var factories: Dictionary = {}

# Statistics tracking
var stats := {
	"spawned": 0,
	"by_rarity": {
		FishData.Rarity.COMMON: 0,
		FishData.Rarity.UNCOMMON: 0,
		FishData.Rarity.RARE: 0,
		FishData.Rarity.EPIC: 0,
		FishData.Rarity.LEGENDARY: 0
	}
}

func _ready():
	_initialize_factories()
	$Timer.wait_time = spawn_interval
	$Timer.start()

func _initialize_factories():
	factories[FishData.Rarity.COMMON] = CommonFishFactory.new()
	factories[FishData.Rarity.UNCOMMON] = CommonFishFactory.new()
	factories[FishData.Rarity.RARE] = RareFishFactory.new()
	factories[FishData.Rarity.EPIC] = RareFishFactory.new()
	factories[FishData.Rarity.LEGENDARY] = LegendaryFishFactory.new()

func _on_timer_timeout() -> void:
	spawn_fish()

func get_random_fish_data() -> FishData:
	# Improved: Weighted selection based on rarity
	return _select_fish_with_rarity_weight()

func spawn_fish():
	# Strategy Pattern: Select fish data with weighted rarity
	var fish_data = get_random_fish_data()
	
	# Factory Pattern: Use appropriate factory based on rarity
	var factory = factories.get(fish_data.rarity, factories[FishData.Rarity.COMMON])
	var fish = factory.create_fish(fish_data)
	
	# Position the fish
	_position_fish(fish)
	
	# Update statistics
	_update_stats(fish_data)
	
	# Add to scene
	get_tree().current_scene.call_deferred("add_child", fish)

func _select_fish_with_rarity_weight() -> FishData:
	# Base weights for fish rarity (makes rare fish actually rare!)
	var base_weights = {
		FishData.Rarity.COMMON: 50,      # 50% base chance - most common
		FishData.Rarity.UNCOMMON: 25,    # 25% base chance - fairly common
		FishData.Rarity.RARE: 15,        # 15% base chance - less common
		FishData.Rarity.EPIC: 8,         # 8% base chance - rare with special abilities
		FishData.Rarity.LEGENDARY: 2     # 2% base chance - very rare with special abilities
	}
	
	# Apply player's luck bonus to rare fish spawning
	var weights = base_weights.duplicate()
	if GlobalVariable.player_ref:
		var luck_bonus = GlobalVariable.player_ref.get_rare_fish_spawn_bonus()
		
		# Redistribute weights - reduce common fish, increase rare fish
		var bonus_multiplier = 1.0 + luck_bonus
		
		# Reduce common/uncommon spawn rates
		weights[FishData.Rarity.COMMON] = int(base_weights[FishData.Rarity.COMMON] * (1.0 - luck_bonus * 0.5))
		weights[FishData.Rarity.UNCOMMON] = int(base_weights[FishData.Rarity.UNCOMMON] * (1.0 - luck_bonus * 0.3))
		
		# Increase rare fish spawn rates
		weights[FishData.Rarity.RARE] = int(base_weights[FishData.Rarity.RARE] * bonus_multiplier)
		weights[FishData.Rarity.EPIC] = int(base_weights[FishData.Rarity.EPIC] * bonus_multiplier)
		weights[FishData.Rarity.LEGENDARY] = int(base_weights[FishData.Rarity.LEGENDARY] * bonus_multiplier)
		
		# Ensure minimum weights
		for rarity in weights:
			weights[rarity] = max(1, weights[rarity])
	
	var filtered_fish = _filter_fish_by_weight(weights)
	return filtered_fish.pick_random()

func _filter_fish_by_weight(weights: Dictionary) -> Array[FishData]:
	var weighted_list: Array[FishData] = []
	
	for fish_data in fish_data_list:
		var weight = weights.get(fish_data.rarity, 1)
		for i in range(weight):
			weighted_list.append(fish_data)
	
	return weighted_list

func _position_fish(fish: Fish):
	var direction = "left" if randf() > 0.5 else "right"
	var spawn_y = randf_range($MinPoint.global_position.y, $MaxPoint.global_position.y)
	var screen_size = get_viewport_rect().size
	
	fish.position = Vector2(screen_size.x, spawn_y) if (direction == "left") else Vector2(0, spawn_y)
	
	# Apply direction to velocity (fish should already have speed from factory)
	if direction == "left":
		fish.velocity.x = -abs(fish.velocity.x)
	else:
		fish.velocity.x = abs(fish.velocity.x)

func _update_stats(fish_data: FishData):
	stats.spawned += 1
	stats.by_rarity[fish_data.rarity] += 1

# Public methods for external access
func get_spawn_stats() -> Dictionary:
	return stats.duplicate()