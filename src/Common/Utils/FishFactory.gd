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
		print("🌟 Spawning rare fish with special movement: ", data.get_movement_pattern())

class LegendaryFishFactory extends BaseFishFactory:
	func _instantiate_fish() -> Fish:
		# Legendary fish could use a different scene with special effects
		# For now, fallback to regular fish scene
		var fish = preload("res://Entities/Fish/Fish.tscn").instantiate()
		print("✨ Creating legendary fish with special abilities!")
		return fish

	func _apply_fish_behavior(fish: Fish, data: FishData) -> void:
		super(fish, data)
		# Legendary fish have special abilities and faster speed
		fish.velocity *= 1.5
		if data.has_special_ability():
			print("🔮 Legendary fish has special ability: ", data.get_special_ability())

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
	print("🐟 Spawning fish with improved factory pattern")
	
	# Strategy Pattern: Select fish data with weighted rarity
	var fish_data = get_random_fish_data()
	
	# Factory Pattern: Use appropriate factory based on rarity
	var factory = factories.get(fish_data.rarity, factories[FishData.Rarity.COMMON])
	var fish = factory.create_fish(fish_data)
	
	# Position the fish
	_position_fish(fish)
	
	# Update statistics
	_update_stats(fish_data)
	
	print("🎯 Created fish: ", fish_data.fish_name, " (", FishData.Rarity.keys()[fish_data.rarity], ")")
	print("📊 Total spawned: ", stats.spawned, " | This rarity: ", stats.by_rarity[fish_data.rarity])
	
	# Add to scene
	get_tree().current_scene.call_deferred("add_child", fish)

func _select_fish_with_rarity_weight() -> FishData:
	# Weighted selection based on rarity (makes rare fish actually rare!)
	var weights = {
		FishData.Rarity.COMMON: 0,      # 50% chance - most common
		FishData.Rarity.UNCOMMON: 0,    # 25% chance - fairly common
		FishData.Rarity.RARE: 0,        # 15% chance - less common
		FishData.Rarity.EPIC: 0,         # 8% chance - rare with special abilities
		FishData.Rarity.LEGENDARY: 100     # 2% chance - very rare with special abilities
	}
	
	var filtered_fish = _filter_fish_by_weight(weights)
	return filtered_fish.pick_random()

func _filter_fish_by_weight(weights: Dictionary) -> Array[FishData]:
	var weighted_list: Array[FishData] = []
	
	# print("🎲 Filtering fish by weight:")
	for fish_data in fish_data_list:
		var weight = weights.get(fish_data.rarity, 1)
		# print("   - ", fish_data.fish_name, " (", FishData.Rarity.keys()[fish_data.rarity], ") weight: ", weight)
		for i in range(weight):
			weighted_list.append(fish_data)
	
	print("📋 Total weighted fish pool size: ", weighted_list.size())
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

func spawn_specific_fish(fish_data: FishData):
	"""Spawn a specific fish - useful for testing or special events"""
	var factory = factories.get(fish_data.rarity, factories[FishData.Rarity.COMMON])
	var fish = factory.create_fish(fish_data)
	_position_fish(fish)
	_update_stats(fish_data)
	get_tree().current_scene.call_deferred("add_child", fish)

func spawn_school_of_fish(count: int, fish_data: FishData):
	"""Spawn multiple fish at once - demonstrates extensibility"""
	for i in range(count):
		var factory = factories.get(fish_data.rarity, factories[FishData.Rarity.COMMON])
		var fish = factory.create_fish(fish_data)
		
		# Spread them out horizontally
		var spawn_y = randf_range($MinPoint.global_position.y, $MaxPoint.global_position.y)
		var screen_size = get_viewport_rect().size
		fish.position = Vector2(screen_size.x + (i * 100), spawn_y)
		fish.velocity.x = -abs(fish.velocity.x)
		
		_update_stats(fish_data)
		get_tree().current_scene.call_deferred("add_child", fish)
