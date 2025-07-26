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
