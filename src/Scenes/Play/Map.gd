extends Node2D
class_name Map

# Map controller for gameplay background management
# Handles random map selection with predefined probabilities

signal map_changed(map_name: String)
signal map_loaded(map_texture: Texture2D)

@export var map_change_interval: float = 120.0  # Time in seconds between potential map changes (2 minutes)
@export var enable_random_changes: bool = true  # Whether maps change automatically during gameplay

# Map configurations with probabilities and effects
var map_configs = {
	"background": {
		"path": "res://Scenes/Play/img/background.png",
		"probability": 0.35,  # 35% chance (increased from 25%)
		"name": "Original Waters",
		"description": "Classic fishing grounds with balanced conditions",
		"player_buffs": {
			"energy_cost": 0.95      # -5% energy cost (familiar waters)
		},
		"player_debuffs": {
			# No significant debuffs (balanced map)
		},
		"fish_buffs": {
			"spawn_rate": 1.1        # +10% spawn rate (well-populated waters)
		},
		"fish_debuffs": {
			# No significant debuffs (balanced map)
		}
	},
	"coral_reef": {
		"path": "res://Scenes/Play/img/coral reef.png",  # Using your actual file
		"probability": 0.3,  # 30% chance (increased from 25%)
		"name": "Coral Reef",
		"description": "Vibrant coral formations teeming with life",
		"player_buffs": {
			"luck_bonus": 0.15,      # +15% luck bonus (diverse ecosystem)
			"rare_fish_spawn": 1.3   # +30% rare fish spawn rate
		},
		"player_debuffs": {
			"movement_speed": 0.9,   # -10% movement speed (obstacles)
			"energy_cost": 1.1       # +10% energy cost (more challenging)
		},
		"fish_buffs": {
			"ability_power": 1.25,   # +25% special ability power (coral cover)
			"speed": 1.1,            # +10% speed (agile reef fish)
			"rare_spawn_rate": 1.4   # +40% rare fish spawn rate
		},
		"fish_debuffs": {
			"escape_chance": 0.9     # -10% escape chance (confined space)
		}
	},
	"deep_sea": {
		"path": "res://Scenes/Play/img/deep_sea.png",  # Using your actual file
		"probability": 0.2,  # 20% chance
		"name": "Deep Sea",
		"description": "Mysterious abyssal depths with rare creatures",
		"player_buffs": {
			"pull_strength": 1.2,    # +20% pull strength (pressure training)
			"legendary_fish_spawn": 1.5  # +50% legendary fish spawn rate
		},
		"player_debuffs": {
			"movement_speed": 0.85,  # -15% movement speed (pressure resistance)
			"energy_cost": 1.2,      # +20% energy cost (deep water strain)
			"luck_bonus": -0.05      # -5% luck bonus (harder to see)
		},
		"fish_buffs": {
			"escape_chance": 1.2,    # +20% escape chance (vast space)
			"ability_power": 1.4,    # +40% special ability power (mysterious powers)
			"speed": 1.15,           # +15% speed (powerful deep-sea fish)
			"legendary_spawn_rate": 2.0  # +100% legendary fish spawn rate
		},
		"fish_debuffs": {
			"common_spawn_rate": 0.7 # -30% common fish spawn rate
		}
	},
	"swamp": {
		"path": "res://Scenes/Play/img/swamp.png",  # Using your actual file
		"probability": 0.15,  # 15% chance (rare environment)
		"name": "Murky Swamp",
		"description": "Mysterious swamp waters with unique species",
		"player_buffs": {
			"energy_cost": 0.85,     # -15% energy cost (buoyant swamp water)
			"pull_strength": 1.1,    # +10% pull strength (dense water resistance training)
			"rare_fish_spawn": 1.2   # +20% rare fish spawn (unique swamp species)
		},
		"player_debuffs": {
			"movement_speed": 0.8,   # -20% movement speed (thick water/vegetation)
			"luck_bonus": -0.1       # -10% luck (murky water reduces visibility)
		},
		"fish_buffs": {
			"ability_power": 1.3,    # +30% special ability power (swamp magic)
			"escape_chance": 1.15,   # +15% escape chance (vegetation cover)
			"rare_spawn_rate": 1.5,  # +50% rare fish spawn (swamp specialties)
			"speed": 0.95            # -5% speed (adapted to thick water)
		},
		"fish_debuffs": {
			"common_spawn_rate": 0.8 # -20% common fish spawn (specialized environment)
		}
	}
}

# Current map state
var current_map: String = ""
var current_texture: Texture2D = null
var map_timer: Timer
var background_sprite: Sprite2D

# Map transition effects
var is_transitioning: bool = false
var transition_duration: float = 1.5
var fade_tween: Tween

func _ready():
	print("Map controller initialized")
	
	# Setup background sprite
	_setup_background_sprite()
	
	# Setup map change timer
	_setup_map_timer()
	
	# Load initial map
	_load_random_map()
	
	# Setup fade tween for transitions
	fade_tween = create_tween()
	fade_tween.kill()  # Stop it initially

func _setup_background_sprite():
	"""Setup the background sprite node"""
	background_sprite = Sprite2D.new()
	background_sprite.name = "MapBackground"
	background_sprite.z_index = -100  # Ensure it's behind everything
	
	# Center the sprite properly
	background_sprite.position = Vector2(640, 360)  # Center of 1280x720 screen
	
	# Scale to match the static background scale from the scene
	background_sprite.scale = Vector2(0.833333, 0.703125)
	
	add_child(background_sprite)
	print("Background sprite created and added at position: " + str(background_sprite.position))

func _setup_map_timer():
	"""Setup timer for automatic map changes"""
	map_timer = Timer.new()
	map_timer.name = "MapChangeTimer"
	map_timer.wait_time = map_change_interval
	map_timer.timeout.connect(_on_map_timer_timeout)
	add_child(map_timer)
	
	if enable_random_changes:
		map_timer.start()
		print("Map change timer started with interval: " + str(map_change_interval) + "s")
	else:
		print("Map change timer created but not started (automatic changes disabled)")

func _on_map_timer_timeout():
	"""Handle automatic map change timer"""
	print("⏰ Map timer timeout triggered! Checking for map change...")
	if not enable_random_changes:
		print("⏰ Timer timeout but random changes disabled - maps only change when entering play stage")
		return
		
	if is_transitioning:
		print("⏰ Timer timeout but transition in progress, skipping")
		return
		
	var chance = randf()
	print("⏰ Random chance: " + str(chance) + " (need < 0.3 to change)")
	if chance < 0.3:  # 30% chance to change map on timer
		print("⏰ Map change triggered by timer!")
		change_to_random_map()
	else:
		print("⏰ No map change this time (chance too high)")

func get_weighted_random_map() -> String:
	"""Select a random map based on probability weights"""
	var total_weight = 0.0
	for config in map_configs.values():
		total_weight += config.probability
	
	var random_value = randf() * total_weight
	var current_weight = 0.0
	
	for map_key in map_configs.keys():
		current_weight += map_configs[map_key].probability
		if random_value <= current_weight:
			return map_key
	
	# Fallback to first map
	return map_configs.keys()[0]

func _load_random_map():
	"""Load a random map at game start"""
	print("Loading initial random map...")
	var selected_map = get_weighted_random_map()
	print("Selected initial map: " + selected_map)
	var result = load_map(selected_map)
	print("Initial map load result: " + str(result))

func load_map(map_key: String, use_transition: bool = false):
	"""Load a specific map by key"""
	if not map_configs.has(map_key):
		print("Warning: Map '" + map_key + "' not found in configurations")
		return false
	
	if is_transitioning:
		print("Map transition already in progress, ignoring request")
		return false
	
	var config = map_configs[map_key]
	print("Loading map: " + config.name)
	
	# Try to load the texture
	var texture = _load_map_texture(config.path)
	if texture == null:
		print("Failed to load map texture: " + config.path)
		return false
	
	if use_transition and current_texture != null:
		_transition_to_map(map_key, texture, config)
	else:
		_set_map_immediately(map_key, texture, config)
	
	return true

func _load_map_texture(path: String) -> Texture2D:
	"""Load texture from path with error handling"""
	if ResourceLoader.exists(path):
		var resource = load(path)
		if resource is Texture2D:
			return resource as Texture2D
		else:
			print("Resource at " + path + " is not a Texture2D")
			return null
	else:
		print("Map texture not found at: " + path)
		# For development: create a placeholder colored texture
		return _create_placeholder_texture(path)

func _create_placeholder_texture(path: String) -> Texture2D:
	"""Create a placeholder texture for missing map files"""
	var image = Image.create(1152, 648, false, Image.FORMAT_RGB8)
	
	# Different colors based on map type
	var color: Color
	if path.contains("background"):
		color = Color(0.3, 0.6, 0.9)  # Medium blue (original style)
	elif path.contains("coral_reef") or path.contains("coral reef"):
		color = Color(0.2, 0.8, 0.8)  # Turquoise
	elif path.contains("deep_ocean") or path.contains("deep_sea"):
		color = Color(0.1, 0.1, 0.5)  # Dark blue
	elif path.contains("swamp"):
		color = Color(0.3, 0.5, 0.2)  # Murky green
	else:
		color = Color(0.5, 0.5, 0.8)  # Default blue
	
	image.fill(color)
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	
	print("Created placeholder texture for: " + path)
	return texture

func _set_map_immediately(map_key: String, texture: Texture2D, config: Dictionary):
	"""Set map without transition"""
	current_map = map_key
	current_texture = texture
	background_sprite.texture = texture
	
	# Ensure transition state is properly reset
	is_transitioning = false
	
	# Emit signals
	map_changed.emit(config.name)
	map_loaded.emit(texture)
	
	print("Map set: " + config.name + " - " + config.description)
	print("Background sprite texture updated")

func _transition_to_map(map_key: String, texture: Texture2D, config: Dictionary):
	"""Transition to new map with fade effect"""
	is_transitioning = true
	
	print("Starting transition to: " + config.name)
	
	# Kill any existing tween first
	if fade_tween:
		fade_tween.kill()
	
	# Create fade out -> change -> fade in sequence
	fade_tween = create_tween()
	fade_tween.tween_property(background_sprite, "modulate:a", 0.0, transition_duration / 2)
	fade_tween.tween_callback(_change_map_texture.bind(map_key, texture, config))
	fade_tween.tween_property(background_sprite, "modulate:a", 1.0, transition_duration / 2)
	fade_tween.tween_callback(_on_transition_complete)
	
	# Safety timeout to prevent getting stuck in transition
	get_tree().create_timer(transition_duration + 1.0).timeout.connect(_force_transition_complete)

func _change_map_texture(map_key: String, texture: Texture2D, config: Dictionary):
	"""Change texture during transition"""
	current_map = map_key
	current_texture = texture
	background_sprite.texture = texture
	
	# Emit signals
	map_changed.emit(config.name)
	map_loaded.emit(texture)
	
	print("Map changed during transition: " + config.name)

func _on_transition_complete():
	"""Called when map transition is complete"""
	is_transitioning = false
	print("Map transition completed")

func _force_transition_complete():
	"""Safety function to force transition completion if stuck"""
	if is_transitioning:
		print("⚠️ Safety timeout: Forcing transition completion")
		is_transitioning = false
		if background_sprite:
			background_sprite.modulate.a = 1.0  # Ensure it's visible

func change_to_random_map():
	"""Change to a random map (different from current)"""
	if is_transitioning:
		print("Cannot change map: transition in progress")
		return false
	
	var available_maps = []
	for map_key in map_configs.keys():
		if map_key != current_map:
			available_maps.append(map_key)
	
	if available_maps.is_empty():
		print("No alternative maps available")
		return false
	
	# Use weighted selection from available maps
	var selected_map = get_weighted_random_map()
	
	# Ensure it's different from current (try up to 3 times)
	var attempts = 0
	while selected_map == current_map and attempts < 3:
		selected_map = get_weighted_random_map()
		attempts += 1
	
	if selected_map == current_map:
		# Force different map
		selected_map = available_maps[randi() % available_maps.size()]
	
	print("🎯 Changing from '" + current_map + "' to '" + selected_map + "'")
	return load_map(selected_map, true)

func debug_map_status():
	"""Print current map system status for debugging"""
	print("🐠 === MAP SYSTEM DEBUG STATUS ===")
	print("Current map: " + str(current_map))
	print("Is transitioning: " + str(is_transitioning))
	print("Timer active: " + str(map_timer.is_connected("timeout", Callable(self, "_on_map_timer_timeout"))))
	print("Timer time left: " + str(map_timer.time_left))
	print("Timer wait time: " + str(map_timer.wait_time))
	print("Timer paused: " + str(map_timer.paused))
	print("===================================")

func force_map_change():
	"""Force an immediate map change (for external triggers)"""
	print("🔄 Force map change requested - Current transition state: " + str(is_transitioning))
	
	# If stuck in transition, reset the state
	if is_transitioning:
		print("⚠️ Warning: Transition was stuck, resetting state")
		is_transitioning = false
		
		# Kill any active tween
		if fade_tween:
			fade_tween.kill()
		
		# Ensure background is visible
		if background_sprite:
			background_sprite.modulate.a = 1.0
	
	# Add debug info
	print("🎮 Current map before change: " + str(current_map))
	var result = change_to_random_map()
	print("🎯 Map change completed with result: " + str(result))
	
	return result

func get_current_map_info() -> Dictionary:
	"""Get information about the current map"""
	if current_map.is_empty():
		return {}
	
	var config = map_configs[current_map].duplicate()
	config["current"] = true
	config["key"] = current_map
	return config

func get_all_map_info() -> Array:
	"""Get information about all available maps"""
	var maps_info = []
	for map_key in map_configs.keys():
		var config = map_configs[map_key].duplicate()
		config["key"] = map_key
		config["current"] = (map_key == current_map)
		maps_info.append(config)
	
	return maps_info

func set_map_change_interval(new_interval: float):
	"""Change the automatic map change interval"""
	map_change_interval = new_interval
	if map_timer:
		map_timer.wait_time = new_interval
	print("Map change interval set to: " + str(new_interval) + "s")

func enable_automatic_changes(enabled: bool):
	"""Enable or disable automatic map changes"""
	enable_random_changes = enabled
	if map_timer:
		if enabled:
			map_timer.start()
			print("Automatic map changes enabled")
		else:
			map_timer.stop()
			print("Automatic map changes disabled")

func get_map_probability(map_key: String) -> float:
	"""Get the probability of a specific map"""
	if map_configs.has(map_key):
		return map_configs[map_key].probability
	return 0.0

func set_map_probability(map_key: String, probability: float):
	"""Set the probability of a specific map"""
	if map_configs.has(map_key):
		map_configs[map_key].probability = clamp(probability, 0.0, 1.0)
		print("Set " + map_key + " probability to: " + str(probability))
	else:
		print("Warning: Map '" + map_key + "' not found")

# Map Effect System - Player Buffs/Debuffs
func get_player_movement_speed_modifier() -> float:
	"""Get current map's effect on player movement speed"""
	if current_map.is_empty():
		return 1.0
	
	var config = map_configs[current_map]
	var modifier = 1.0
	
	if config.has("player_buffs") and config.player_buffs.has("movement_speed"):
		modifier *= config.player_buffs.movement_speed
	
	if config.has("player_debuffs") and config.player_debuffs.has("movement_speed"):
		modifier *= config.player_debuffs.movement_speed
	
	return modifier

func get_player_energy_cost_modifier() -> float:
	"""Get current map's effect on player energy cost"""
	if current_map.is_empty():
		return 1.0
	
	var config = map_configs[current_map]
	var modifier = 1.0
	
	if config.has("player_buffs") and config.player_buffs.has("energy_cost"):
		modifier *= config.player_buffs.energy_cost
	
	if config.has("player_debuffs") and config.player_debuffs.has("energy_cost"):
		modifier *= config.player_debuffs.energy_cost
	
	return modifier

func get_player_pull_strength_modifier() -> float:
	"""Get current map's effect on player pull strength"""
	if current_map.is_empty():
		return 1.0
	
	var config = map_configs[current_map]
	var modifier = 1.0
	
	if config.has("player_buffs") and config.player_buffs.has("pull_strength"):
		modifier *= config.player_buffs.pull_strength
	
	if config.has("player_debuffs") and config.player_debuffs.has("pull_strength"):
		modifier *= config.player_debuffs.pull_strength
	
	return modifier

func get_player_luck_bonus_modifier() -> float:
	"""Get current map's effect on player luck bonus"""
	if current_map.is_empty():
		return 0.0
	
	var config = map_configs[current_map]
	var bonus = 0.0
	
	if config.has("player_buffs") and config.player_buffs.has("luck_bonus"):
		bonus += config.player_buffs.luck_bonus
	
	if config.has("player_debuffs") and config.player_debuffs.has("luck_bonus"):
		bonus += config.player_debuffs.luck_bonus
	
	return bonus

func get_rare_fish_spawn_modifier() -> float:
	"""Get current map's effect on rare fish spawn rates"""
	if current_map.is_empty():
		return 1.0
	
	var config = map_configs[current_map]
	var modifier = 1.0
	
	if config.has("player_buffs") and config.player_buffs.has("rare_fish_spawn"):
		modifier *= config.player_buffs.rare_fish_spawn
	
	if config.has("fish_buffs") and config.fish_buffs.has("rare_spawn_rate"):
		modifier *= config.fish_buffs.rare_spawn_rate
	
	return modifier

func get_legendary_fish_spawn_modifier() -> float:
	"""Get current map's effect on legendary fish spawn rates"""
	if current_map.is_empty():
		return 1.0
	
	var config = map_configs[current_map]
	var modifier = 1.0
	
	if config.has("player_buffs") and config.player_buffs.has("legendary_fish_spawn"):
		modifier *= config.player_buffs.legendary_fish_spawn
	
	if config.has("fish_buffs") and config.fish_buffs.has("legendary_spawn_rate"):
		modifier *= config.fish_buffs.legendary_spawn_rate
	
	return modifier

# Map Effect System - Fish Buffs/Debuffs
func get_fish_speed_modifier() -> float:
	"""Get current map's effect on fish speed"""
	if current_map.is_empty():
		return 1.0
	
	var config = map_configs[current_map]
	var modifier = 1.0
	
	if config.has("fish_buffs") and config.fish_buffs.has("speed"):
		modifier *= config.fish_buffs.speed
	
	if config.has("fish_debuffs") and config.fish_debuffs.has("speed"):
		modifier *= config.fish_debuffs.speed
	
	return modifier

func get_fish_escape_chance_modifier() -> float:
	"""Get current map's effect on fish escape chance"""
	if current_map.is_empty():
		return 1.0
	
	var config = map_configs[current_map]
	var modifier = 1.0
	
	if config.has("fish_buffs") and config.fish_buffs.has("escape_chance"):
		modifier *= config.fish_buffs.escape_chance
	
	if config.has("fish_debuffs") and config.fish_debuffs.has("escape_chance"):
		modifier *= config.fish_debuffs.escape_chance
	
	return modifier

func get_fish_ability_power_modifier() -> float:
	"""Get current map's effect on fish special ability power"""
	if current_map.is_empty():
		return 1.0
	
	var config = map_configs[current_map]
	var modifier = 1.0
	
	if config.has("fish_buffs") and config.fish_buffs.has("ability_power"):
		modifier *= config.fish_buffs.ability_power
	
	if config.has("fish_debuffs") and config.fish_debuffs.has("ability_power"):
		modifier *= config.fish_debuffs.ability_power
	
	return modifier

func get_fish_spawn_rate_modifier() -> float:
	"""Get current map's effect on general fish spawn rate"""
	if current_map.is_empty():
		return 1.0
	
	var config = map_configs[current_map]
	var modifier = 1.0
	
	if config.has("fish_buffs") and config.fish_buffs.has("spawn_rate"):
		modifier *= config.fish_buffs.spawn_rate
	
	if config.has("fish_debuffs") and config.fish_debuffs.has("spawn_rate"):
		modifier *= config.fish_debuffs.spawn_rate
	
	return modifier

func get_common_fish_spawn_modifier() -> float:
	"""Get current map's effect on common fish spawn rate"""
	if current_map.is_empty():
		return 1.0
	
	var config = map_configs[current_map]
	var modifier = 1.0
	
	if config.has("fish_buffs") and config.fish_buffs.has("common_spawn_rate"):
		modifier *= config.fish_buffs.common_spawn_rate
	
	if config.has("fish_debuffs") and config.fish_debuffs.has("common_spawn_rate"):
		modifier *= config.fish_debuffs.common_spawn_rate
	
	return modifier

# Comprehensive effect getter for external systems
func get_all_current_map_effects() -> Dictionary:
	"""Get all current map effects in a single dictionary"""
	if current_map.is_empty():
		return {}
	
	return {
		"map_name": current_map,
		"display_name": map_configs[current_map].name,
		"player_effects": {
			"movement_speed_modifier": get_player_movement_speed_modifier(),
			"energy_cost_modifier": get_player_energy_cost_modifier(),
			"pull_strength_modifier": get_player_pull_strength_modifier(),
			"luck_bonus_modifier": get_player_luck_bonus_modifier(),
		},
		"fish_effects": {
			"speed_modifier": get_fish_speed_modifier(),
			"escape_chance_modifier": get_fish_escape_chance_modifier(),
			"ability_power_modifier": get_fish_ability_power_modifier(),
			"spawn_rate_modifier": get_fish_spawn_rate_modifier(),
		},
		"spawn_modifiers": {
			"common_fish": get_common_fish_spawn_modifier(),
			"rare_fish": get_rare_fish_spawn_modifier(),
			"legendary_fish": get_legendary_fish_spawn_modifier(),
		}
	}

# Event handlers for external systems
func _on_special_event_triggered(event_type: String):
	"""Handle special events that might trigger map changes"""
	match event_type:
		"storm":
			load_map("deep_ocean", true)
		"calm_weather":
			load_map("ocean_surface", true)
		"treasure_hunt":
			load_map("coral_reef", true)
		_:
			print("Unknown event type: " + event_type)

func _on_player_level_changed(new_level: int):
	"""Adjust map probabilities based on player level"""
	if new_level >= 10:
		# Higher level players see deep sea more often, less background
		set_map_probability("background", 0.25)
		set_map_probability("coral_reef", 0.35)
		set_map_probability("deep_sea", 0.25)
		set_map_probability("swamp", 0.15)
	elif new_level >= 5:
		# Mid-level balanced distribution
		set_map_probability("background", 0.35)
		set_map_probability("coral_reef", 0.35)
		set_map_probability("deep_sea", 0.2)
		set_map_probability("swamp", 0.1)
	else:
		# Beginners see background more often, less challenging maps
		set_map_probability("background", 0.5)
		set_map_probability("coral_reef", 0.25)
		set_map_probability("deep_sea", 0.15)
		set_map_probability("swamp", 0.1)

func _input(event):
	"""Handle debug input"""
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_M:
			print("🔄 Manual map change triggered by M key")
			var result = force_map_change()
			print("🔄 Force map change result: " + str(result))
		elif event.keycode == KEY_I:
			debug_map_status()
