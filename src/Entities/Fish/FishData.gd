class_name FishData
extends Resource

# Strategy Pattern for Fish Behavior
class FishBehaviorStrategy extends RefCounted:
	func get_movement_pattern() -> String:
		return "straight"
	
	func get_special_ability() -> String:
		return "none"
	
	func get_catch_difficulty() -> float:
		return 1.0
	
	# New methods for special ability implementation
	func can_use_special_ability() -> bool:
		return get_special_ability() != "none"
	
	func get_ability_cooldown() -> float:
		return 0.0
	
	func get_ability_duration() -> float:
		return 0.0
	
	func apply_special_ability(_fish: Fish) -> void:
		# Base implementation does nothing
		pass
	
	func remove_special_ability(_fish: Fish) -> void:
		# Base implementation does nothing
		pass

class CommonBehavior extends FishBehaviorStrategy:
	func get_movement_pattern() -> String:
		return "straight"

class UncommonBehavior extends FishBehaviorStrategy:
	func get_movement_pattern() -> String:
		return "slight_wave"

class RareBehavior extends FishBehaviorStrategy:
	func get_movement_pattern() -> String:
		return "zigzag"
	
	func get_catch_difficulty() -> float:
		return 1.3

class EpicBehavior extends FishBehaviorStrategy:
	func get_movement_pattern() -> String:
		return "circular"
	
	func get_special_ability() -> String:
		return "dash"
	
	func get_catch_difficulty() -> float:
		return 1.6
	
	func get_ability_cooldown() -> float:
		return 3.0  # 3 seconds cooldown
	
	func get_ability_duration() -> float:
		return 1.0  # 1 second duration
	
	func apply_special_ability(fish: Fish) -> void:
		# Dash ability: temporarily increase speed
		var original_speed = fish.velocity.length()
		fish.velocity = fish.velocity.normalized() * (original_speed * 2.5)
		print("⚡ Epic fish uses DASH! Speed boosted!")
	
	func remove_special_ability(fish: Fish) -> void:
		# Restore normal speed
		if fish.fish_data:
			var normal_speed = fish.fish_data.get_effective_speed()
			fish.velocity = fish.velocity.normalized() * normal_speed
		print("⚡ Dash effect ended")

class LegendaryBehavior extends FishBehaviorStrategy:
	func get_movement_pattern() -> String:
		return "teleport"
	
	func get_special_ability() -> String:
		return "invisibility"
	
	func get_catch_difficulty() -> float:
		return 2.0
	
	func get_ability_cooldown() -> float:
		return 5.0  # 5 seconds cooldown
	
	func get_ability_duration() -> float:
		return 2.0  # 2 seconds duration
	
	func apply_special_ability(fish: Fish) -> void:
		# Invisibility ability: make fish nearly transparent and harder to catch
		if fish.has_node("Sprite2D"):
			var sprite = fish.get_node("Sprite2D")
			sprite.modulate.a = 0.3  # Make 70% transparent
		
		# Teleport to safe position using fish's boundary checking
		if fish.has_method("_get_safe_teleport_position"):
			fish.position = fish._get_safe_teleport_position()
		else:
			# Fallback: use screen bounds with safety margin
			var screen_size = fish.get_viewport_rect().size
			var margin = 100.0
			var new_x = randf_range(margin, screen_size.x - margin)
			var new_y = randf_range(margin, screen_size.y - margin)
			fish.position = Vector2(new_x, new_y)
		
		print("👻 Legendary fish uses INVISIBILITY and TELEPORTS!")
	
	func remove_special_ability(fish: Fish) -> void:
		# Restore visibility
		if fish.has_node("Sprite2D"):
			var sprite = fish.get_node("Sprite2D")
			sprite.modulate.a = 1.0  # Full opacity
		print("👻 Invisibility effect ended")

enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY}

@export var fish_name : String
@export var rarity : Rarity
@export var sprite_texture : Texture2D

var behavior_strategy: FishBehaviorStrategy
var rarity_stats := {
	Rarity.COMMON: {
		"speed" = 3,     # Reasonable base speed for common fish
		"strength" = 5,
		"value" = 1,
	},
	Rarity.UNCOMMON: {
		"speed" = 3,     # Slightly faster
		"strength" = 10,
		"value" = 3,
	},
	Rarity.RARE: {
		"speed" = 3,     # Noticeably faster
		"strength" = 15,
		"value" = 5,
	},
	Rarity.EPIC: {
		"speed" = 3,     # Much faster
		"strength" = 20,
		"value" = 10,
	},
	Rarity.LEGENDARY: {
		"speed" = 3,    # Very fast
		"strength" = 25,
		"value" = 20,
	},
}

func _init():
	# Don't initialize behavior strategy here - properties aren't loaded yet
	pass

func _initialize_behavior_strategy():
	# Ensure we have valid data before initializing
	if fish_name == null or fish_name == "":
		print("⚠️ Warning: fish_name not set, using default")
		fish_name = "Unknown Fish"
	
	# Ensure rarity is valid
	if rarity < 0 or rarity >= Rarity.size():
		print("⚠️ Warning: Invalid rarity value ", rarity, ", defaulting to COMMON")
		rarity = Rarity.COMMON
	
	print("🔧 Initializing behavior for ", fish_name, " with rarity: ", rarity, " (", Rarity.keys()[rarity], ")")
	
	match rarity:
		Rarity.COMMON:
			behavior_strategy = CommonBehavior.new()
			print("   → CommonBehavior (no special ability)")
		Rarity.UNCOMMON:
			behavior_strategy = UncommonBehavior.new()
			print("   → UncommonBehavior (no special ability)")
		Rarity.RARE:
			behavior_strategy = RareBehavior.new()
			print("   → RareBehavior (no special ability)")
		Rarity.EPIC:
			behavior_strategy = EpicBehavior.new()
			print("   → EpicBehavior (DASH ability)")
		Rarity.LEGENDARY:
			behavior_strategy = LegendaryBehavior.new()
			print("   → LegendaryBehavior (INVISIBILITY ability)")
		_:
			behavior_strategy = CommonBehavior.new()
			print("   → DEFAULT: CommonBehavior (rarity not recognized: ", rarity, ")")

# Lazy initialization - call this when behavior_strategy is needed
func get_behavior_strategy() -> FishBehaviorStrategy:
	if behavior_strategy == null:
		_initialize_behavior_strategy()
	return behavior_strategy

func get_stat(stat : String) -> Variant:
	return rarity_stats.get(rarity, {}).get(stat, null)

# New methods using Strategy Pattern
func get_effective_speed() -> float:
	# Return the base speed directly - no more double multiplication
	return get_stat("speed")

func get_movement_pattern() -> String:
	return get_behavior_strategy().get_movement_pattern()

func get_special_ability() -> String:
	return get_behavior_strategy().get_special_ability()

func get_catch_difficulty() -> float:
	var base_difficulty = get_behavior_strategy().get_catch_difficulty()
	
	# Apply player stats to modify catch difficulty
	if GlobalVariable.player_ref:
		var player_modifier = GlobalVariable.player_ref.get_fish_catch_difficulty_modifier()
		base_difficulty *= player_modifier
		# Ensure minimum difficulty
		base_difficulty = max(0.3, base_difficulty)
	
	return base_difficulty

# Behavior delegation methods
func has_special_ability() -> bool:
	return get_special_ability() != "none"

func get_ability_cooldown() -> float:
	return get_behavior_strategy().get_ability_cooldown()

func get_ability_duration() -> float:
	return get_behavior_strategy().get_ability_duration()

func can_use_special_ability() -> bool:
	return get_behavior_strategy().can_use_special_ability()

func apply_special_ability(fish: Fish) -> void:
	get_behavior_strategy().apply_special_ability(fish)

func remove_special_ability(fish: Fish) -> void:
	get_behavior_strategy().remove_special_ability(fish)
