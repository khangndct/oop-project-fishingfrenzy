extends Node

var is_fish_being_caught := false
var hook_ref : Node = null
var rod_ref : Rod = null
var player_ref : Player = null
var hud_ref : CanvasLayer = null
var money : int = 0

# Player persistent stats
var player_strength : int = 1
var player_speed_stat : int = 1
var player_vitality : int = 1
var player_luck : int = 1
var player_energy : int = 100

# Player fractional stats for gradual progression
var player_fractional_strength : float = 0.0
var player_fractional_speed : float = 0.0
var player_fractional_vitality : float = 0.0
var player_fractional_luck : float = 0.0

# Potion effects - Fish Slow Potions
var has_fish_slow_potion_30: bool = false
var has_fish_slow_potion_50: bool = false  
var has_fish_slow_potion_70: bool = false

# Potion effects - Player Speed Potions
var has_player_speed_potion_20: bool = false
var has_player_speed_potion_30: bool = false
var has_player_speed_potion_40: bool = false

# Potion effects - Rod Buff Potions
var has_rod_buff_potion_30: bool = false
var has_rod_buff_potion_50: bool = false
var has_rod_buff_potion_70: bool = false

# Fortune Food effects
var has_great_fortune_food: bool = false
var has_super_fortune_food: bool = false
var has_ultra_fortune_food: bool = false

# Energy Food effects
var has_recovery_energy_food: bool = false
var has_mighty_energy_food: bool = false
var has_grand_energy_food: bool = false
var mighty_energy_fish_count: int = 0  # Track fish caught with mighty energy food
var grand_energy_fish_count: int = 0   # Track fish caught with grand energy food

# Level and Quest System
enum GameLevel { EASY, NORMAL, HARD }
var current_level: GameLevel = GameLevel.EASY
var unlocked_levels: Array = [GameLevel.EASY]
var level_completed: Dictionary = {
	GameLevel.EASY: false,
	GameLevel.NORMAL: false,
	GameLevel.HARD: false
}

# Quest tracking for current session
var current_session_fish_caught: int = 0
var current_session_rare_or_better: int = 0
var current_session_epic_or_better: int = 0  
var current_session_legendary_or_better: int = 0
var current_session_potions_used: int = 0
var current_session_foods_used: int = 0
var current_session_start_time: float = 0.0

# Fish count by rarity for current session
var current_session_common_fish: int = 0
var current_session_uncommon_fish: int = 0
var current_session_rare_fish: int = 0
var current_session_epic_fish: int = 0
var current_session_legendary_fish: int = 0
var current_session_money_earned: int = 0

# Legacy variables (for backward compatibility)
var has_slow_potion: bool = false
var has_speed_potion: bool = false

# UI elements for caught fish display
var caught_fish_ui : Control = null
var caught_fish_label : Label = null
var caught_fish_timer : Timer = null

func _ready():
	_setup_caught_fish_ui()

func _setup_caught_fish_ui():
	"""Setup UI elements for displaying caught fish information"""
	if not caught_fish_ui:
		# Create main container
		caught_fish_ui = Control.new()
		caught_fish_ui.name = "CaughtFishUI"
		caught_fish_ui.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
		caught_fish_ui.position = Vector2(-120, 10)  # Right side of screen, small offset
		caught_fish_ui.size = Vector2(110, 40)
		
		# Create background panel
		var panel = Panel.new()
		panel.size = Vector2(110, 40)
		panel.add_theme_color_override("bg_color", Color(0, 0, 0, 0.8))
		caught_fish_ui.add_child(panel)
		
		# Create label for fish info
		caught_fish_label = Label.new()
		caught_fish_label.size = Vector2(110, 40)
		caught_fish_label.add_theme_font_size_override("font_size", 10)
		caught_fish_label.add_theme_color_override("font_color", Color.WHITE)
		caught_fish_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caught_fish_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		caught_fish_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		caught_fish_ui.add_child(caught_fish_label)
		
		# Create timer for auto-hide
		caught_fish_timer = Timer.new()
		caught_fish_timer.wait_time = 3.0  # Show for 3 seconds
		caught_fish_timer.one_shot = true
		caught_fish_timer.timeout.connect(_hide_caught_fish_ui)
		caught_fish_ui.add_child(caught_fish_timer)
		
		# Initially hidden
		caught_fish_ui.visible = false
		
		# Add to scene tree (will be added to current scene's UI layer)
		get_tree().current_scene.add_child(caught_fish_ui)

func show_caught_fish(fish_name: String, rarity: FishData.Rarity):
	"""Display caught fish information on the right side of the screen"""
	if not caught_fish_ui or not caught_fish_label:
		_setup_caught_fish_ui()
		return
	
	var rarity_name = FishData.Rarity.keys()[rarity]
	var rarity_color = _get_rarity_color(rarity)
	
	# Set the text and color
	caught_fish_label.text = "🎣 CAUGHT!\n" + fish_name + "\n" + rarity_name
	caught_fish_label.add_theme_color_override("font_color", rarity_color)
	
	# Show the UI
	caught_fish_ui.visible = true
	
	# Start the auto-hide timer
	caught_fish_timer.start()
	
func _hide_caught_fish_ui():
	"""Hide the caught fish UI"""
	if caught_fish_ui:
		caught_fish_ui.visible = false

func _get_rarity_color(rarity: FishData.Rarity) -> Color:
	"""Return color based on fish rarity"""
	match rarity:
		FishData.Rarity.COMMON:
			return Color.WHITE
		FishData.Rarity.UNCOMMON:
			return Color.GREEN
		FishData.Rarity.RARE:
			return Color.BLUE
		FishData.Rarity.EPIC:
			return Color.MAGENTA
		FishData.Rarity.LEGENDARY:
			return Color.GOLD
		_:
			return Color.WHITE

# Helper functions for potion effects
func get_fish_slow_effect() -> float:
	"""Return the highest fish slow effect (as decimal, e.g., 0.3 for 30%)"""
	if has_fish_slow_potion_70:
		return 0.70
	elif has_fish_slow_potion_50:
		return 0.50
	elif has_fish_slow_potion_30:
		return 0.30
	elif has_slow_potion:  # Legacy support
		return 0.90
	return 0.0

func get_player_speed_effect() -> float:
	"""Return the highest player speed effect (as decimal, e.g., 0.2 for 20%)"""
	if has_player_speed_potion_40:
		return 0.40
	elif has_player_speed_potion_30:
		return 0.30
	elif has_player_speed_potion_20:
		return 0.20
	elif has_speed_potion:  # Legacy support
		return 0.20
	return 0.0

func get_rod_buff_effect() -> float:
	"""Return the highest rod buff effect (as decimal, e.g., 0.3 for 30%)"""
	if has_rod_buff_potion_70:
		return 0.70
	elif has_rod_buff_potion_50:
		return 0.50
	elif has_rod_buff_potion_30:
		return 0.30
	return 0.0

func has_any_fish_slow_potion() -> bool:
	"""Check if any fish slow potion is active"""
	return has_fish_slow_potion_30 or has_fish_slow_potion_50 or has_fish_slow_potion_70 or has_slow_potion

func has_any_player_speed_potion() -> bool:
	"""Check if any player speed potion is active"""
	return has_player_speed_potion_20 or has_player_speed_potion_30 or has_player_speed_potion_40 or has_speed_potion

func has_any_rod_buff_potion() -> bool:
	"""Check if any rod buff potion is active"""
	return has_rod_buff_potion_30 or has_rod_buff_potion_50 or has_rod_buff_potion_70

func save_active_potion_effects():
	"""Save current active potion effects to temporary storage for session persistence"""
	# This will be called when going back to main menu to preserve effects
	pass

func restore_active_potion_effects():
	"""Restore potion effects when returning to gameplay"""
	# Effects are already persistent in the global variables
	# This function exists for future enhancements if needed
	pass

func clear_session_potions():
	"""Clear all session-based potion effects (call this only when starting a new game session)"""
	# Fish slow potions are session-based
	has_fish_slow_potion_30 = false
	has_fish_slow_potion_50 = false
	has_fish_slow_potion_70 = false
	
	# Player speed potions are session-based
	has_player_speed_potion_20 = false
	has_player_speed_potion_30 = false
	has_player_speed_potion_40 = false
	
	# Rod buff potions are session-based
	has_rod_buff_potion_30 = false
	has_rod_buff_potion_50 = false
	has_rod_buff_potion_70 = false
	
	# Legacy potions
	has_slow_potion = false
	has_speed_potion = false
	
	# Clear food effects (they are also session-based)
	has_great_fortune_food = false
	has_super_fortune_food = false
	has_ultra_fortune_food = false
	has_recovery_energy_food = false
	has_mighty_energy_food = false
	has_grand_energy_food = false
	mighty_energy_fish_count = 0
	grand_energy_fish_count = 0

# Fortune food helper functions
func get_fortune_multiplier_rare() -> float:
	"""Return fortune multiplier for RARE fish"""
	if has_ultra_fortune_food or has_super_fortune_food or has_great_fortune_food:
		return 2.0  # All fortune foods give x2 for RARE
	return 1.0

func get_fortune_multiplier_epic() -> float:
	"""Return fortune multiplier for EPIC fish"""
	if has_super_fortune_food or has_ultra_fortune_food:
		return 3.0  # Super and Ultra give x3 for EPIC
	elif has_great_fortune_food:
		return 2.0  # Great gives x2 for EPIC
	return 1.0

func get_fortune_multiplier_legendary() -> float:
	"""Return fortune multiplier for LEGENDARY fish"""
	if has_ultra_fortune_food:
		return 4.0  # Ultra gives x4 for LEGENDARY
	elif has_super_fortune_food:
		return 3.0  # Super gives x3 for LEGENDARY
	elif has_great_fortune_food:
		return 2.0  # Great gives x2 for LEGENDARY
	return 1.0

func has_any_fortune_food() -> bool:
	"""Check if any fortune food is active"""
	return has_great_fortune_food or has_super_fortune_food or has_ultra_fortune_food

# Energy food helper functions
func get_energy_cost_modifier() -> int:
	"""Return modified energy cost per fish"""
	if has_mighty_energy_food or has_grand_energy_food:
		return 1  # Reduced to 1 energy per fish
	return 2  # Default cost

func has_any_energy_food() -> bool:
	"""Check if any energy food is active"""
	return has_recovery_energy_food or has_mighty_energy_food or has_grand_energy_food

func on_fish_caught():
	"""Call this when a fish is caught to update energy food counters"""
	if has_mighty_energy_food:
		mighty_energy_fish_count += 1
		if mighty_energy_fish_count >= 50:
			has_mighty_energy_food = false
			mighty_energy_fish_count = 0
			print("Mighty Energy Food effect expired after 50 fish!")
	
	if has_grand_energy_food:
		grand_energy_fish_count += 1
		if grand_energy_fish_count >= 100:
			has_grand_energy_food = false
			grand_energy_fish_count = 0
			print("Grand Energy Food effect expired after 100 fish!")

# Level and Quest System Functions
func start_level_session():
	"""Initialize session tracking when starting a level"""
	current_session_fish_caught = 0
	current_session_rare_or_better = 0
	current_session_epic_or_better = 0
	current_session_legendary_or_better = 0
	current_session_potions_used = 0
	current_session_foods_used = 0
	current_session_start_time = Time.get_time_dict_from_system()["second"] + Time.get_time_dict_from_system()["minute"] * 60 + Time.get_time_dict_from_system()["hour"] * 3600
	
	# Reset fish count by rarity
	current_session_common_fish = 0
	current_session_uncommon_fish = 0
	current_session_rare_fish = 0
	current_session_epic_fish = 0
	current_session_legendary_fish = 0
	current_session_money_earned = 0

func track_fish_caught(rarity: FishData.Rarity):
	"""Track fish caught in current session"""
	current_session_fish_caught += 1
	
	# Count by rarity
	match rarity:
		FishData.Rarity.COMMON:
			current_session_common_fish += 1
		FishData.Rarity.UNCOMMON:
			current_session_uncommon_fish += 1
		FishData.Rarity.RARE:
			current_session_rare_fish += 1
			current_session_rare_or_better += 1
		FishData.Rarity.EPIC:
			current_session_epic_fish += 1
			current_session_rare_or_better += 1
			current_session_epic_or_better += 1
		FishData.Rarity.LEGENDARY:
			current_session_legendary_fish += 1
			current_session_rare_or_better += 1
			current_session_epic_or_better += 1
			current_session_legendary_or_better += 1

func track_potion_used():
	"""Track potion usage"""
	current_session_potions_used += 1

func track_food_used():
	"""Track food usage"""
	current_session_foods_used += 1

func get_current_level_requirements() -> Dictionary:
	"""Get requirements for current level"""
	match current_level:
		GameLevel.EASY:
			return {
				"total_fish": 50,
				"rare_or_better": 5,
				"epic_or_better": 0,
				"legendary_or_better": 0
			}
		GameLevel.NORMAL:
			return {
				"total_fish": 100,
				"rare_or_better": 0,
				"epic_or_better": 20,
				"legendary_or_better": 0
			}
		GameLevel.HARD:
			return {
				"total_fish": 300,
				"rare_or_better": 0,
				"epic_or_better": 0,
				"legendary_or_better": 50
			}
	return {}

func is_level_completed() -> bool:
	"""Check if current level is completed"""
	var requirements = get_current_level_requirements()
	
	if current_session_fish_caught < requirements.total_fish:
		return false
	
	if requirements.rare_or_better > 0 and current_session_rare_or_better < requirements.rare_or_better:
		return false
		
	if requirements.epic_or_better > 0 and current_session_epic_or_better < requirements.epic_or_better:
		return false
		
	if requirements.legendary_or_better > 0 and current_session_legendary_or_better < requirements.legendary_or_better:
		return false
	
	return true

func complete_current_level():
	"""Mark current level as completed and unlock next level"""
	level_completed[current_level] = true
	
	# Unlock next level
	match current_level:
		GameLevel.EASY:
			if not GameLevel.NORMAL in unlocked_levels:
				unlocked_levels.append(GameLevel.NORMAL)
		GameLevel.NORMAL:
			if not GameLevel.HARD in unlocked_levels:
				unlocked_levels.append(GameLevel.HARD)

func get_level_name(level: GameLevel) -> String:
	"""Get display name for level"""
	match level:
		GameLevel.EASY:
			return "Easy"
		GameLevel.NORMAL:
			return "Normal"
		GameLevel.HARD:
			return "Hard"
	return "Unknown"

func get_session_duration() -> float:
	"""Get current session duration in seconds"""
	var current_time = Time.get_time_dict_from_system()["second"] + Time.get_time_dict_from_system()["minute"] * 60 + Time.get_time_dict_from_system()["hour"] * 3600
	return current_time - current_session_start_time
