extends Control

class_name PlayerStatsMenu

@onready var player_picture = $BackgroundPanel/ContentContainer/LeftPanel/PlayerPicture
@onready var stats_container = $BackgroundPanel/ContentContainer/LeftPanel/StatsContainer
@onready var buffs_container = $BackgroundPanel/ContentContainer/RightPanel/BuffsContainer
@onready var close_button = $BackgroundPanel/CloseButton

var player_ref: Player

func _ready():
	# Hide by default
	visible = false
	
	# Connect close button
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)
		# Prevent button from keeping focus after click
		close_button.focus_mode = Control.FOCUS_NONE
	
	# Load player picture
	_load_player_picture()

func _load_player_picture():
	"""Load and set the player picture"""
	if player_picture:
		var player_texture = load("res://Assets/Img/Player/Player.svg") as Texture2D
		if player_texture:
			player_picture.texture = player_texture

func show_menu():
	"""Display the player stats menu"""
	# Try to get player reference from GlobalVariable first
	if not player_ref and GlobalVariable.player_ref:
		player_ref = GlobalVariable.player_ref
	
	# If still no player reference, try to find it in the scene tree
	if not player_ref:
		var play_scene = get_tree().current_scene
		if play_scene:
			var player_node = play_scene.get_node_or_null("Player")
			if player_node:
				player_ref = player_node
	
	if not player_ref:
		return
	
	_update_stats_display()
	_update_buffs_display()
	visible = true

func hide_menu():
	"""Hide the player stats menu"""
	visible = false

func _on_close_button_pressed():
	# Update parent's UI state first, then hide
	var play_scene = get_tree().current_scene
	if play_scene and play_scene.has_method("_close_stats_menu"):
		play_scene._close_stats_menu()
	else:
		# Fallback if not called from Play scene
		hide_menu()

func _update_stats_display():
	"""Update the stats display on the left side"""
	if not player_ref or not stats_container:
		return
		
	# Clear existing stats labels - use remove_child and queue_free
	for child in stats_container.get_children():
		stats_container.remove_child(child)
		child.queue_free()
	
	# Create stats title
	var stats_title = Label.new()
	stats_title.text = "Base Stats"
	stats_title.add_theme_font_size_override("font_size", 16)
	stats_title.add_theme_color_override("font_color", Color.YELLOW)
	stats_container.add_child(stats_title)
	
	# Add separator
	var separator = HSeparator.new()
	stats_container.add_child(separator)
	
	# Create stats labels with bigger font
	var stats_data = [
		{"name": "Strength", "base": player_ref.strength, "bonus": _get_strength_bonus()},
		{"name": "Speed", "base": player_ref.speed_stat, "bonus": _get_speed_bonus()},
		{"name": "Vitality", "base": player_ref.vitality, "bonus": _get_vitality_bonus()},
		{"name": "Luck", "base": player_ref.luck, "bonus": _get_luck_bonus()}
	]
	
	for stat in stats_data:
		var stat_label = Label.new()
		
		# Get fractional progress for the stat
		var progress = 0.0
		match stat.name:
			"Strength":
				progress = player_ref.get_fractional_strength_progress()
			"Speed":
				progress = player_ref.get_fractional_speed_progress()
			"Vitality":
				progress = player_ref.get_fractional_vitality_progress()
			"Luck":
				progress = player_ref.get_fractional_luck_progress()
		
		# Format display with progress
		var progress_text = ""
		if progress > 0.0:
			progress_text = " (%.1f%%)" % (progress * 100)
		
		if stat.bonus > 0:
			stat_label.text = "%s: %d (+%d)%s" % [stat.name, stat.base, stat.bonus, progress_text]
		else:
			stat_label.text = "%s: %d%s" % [stat.name, stat.base, progress_text]
			
		stat_label.add_theme_font_size_override("font_size", 18)
		stat_label.add_theme_color_override("font_color", Color.WHITE)
		stats_container.add_child(stat_label)
	
	# Add energy information
	var energy_separator = HSeparator.new()
	stats_container.add_child(energy_separator)
	
	var energy_title = Label.new()
	energy_title.text = "Energy"
	energy_title.add_theme_font_size_override("font_size", 16)
	energy_title.add_theme_color_override("font_color", Color.CYAN)
	stats_container.add_child(energy_title)
	
	var energy_label = Label.new()
	energy_label.text = "Current: %d / %d" % [player_ref.energy, player_ref.max_energy]
	energy_label.add_theme_font_size_override("font_size", 14)
	energy_label.add_theme_color_override("font_color", Color.WHITE)
	stats_container.add_child(energy_label)
	
	var energy_cost_label = Label.new()
	energy_cost_label.text = "Cost per fish: %d" % player_ref.get_energy_cost()
	energy_cost_label.add_theme_font_size_override("font_size", 14)
	energy_cost_label.add_theme_color_override("font_color", Color.WHITE)
	stats_container.add_child(energy_cost_label)
	
	# Add money information
	var money_separator = HSeparator.new()
	stats_container.add_child(money_separator)
	
	var money_label = Label.new()
	money_label.text = "Money: $%d" % GlobalVariable.money
	money_label.add_theme_font_size_override("font_size", 16)
	money_label.add_theme_color_override("font_color", Color.GOLD)
	stats_container.add_child(money_label)

func _update_buffs_display():
	"""Update the buffs/upgrades display on the right side"""
	if not buffs_container:
		return
		
	# Clear existing buff labels - use remove_child and queue_free
	for child in buffs_container.get_children():
		buffs_container.remove_child(child)
		child.queue_free()
	
	# Create title label
	var title_label = Label.new()
	title_label.text = "Active Buffs & Effects"
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.add_theme_color_override("font_color", Color.YELLOW)
	buffs_container.add_child(title_label)
	
	# Add separator
	var separator = HSeparator.new()
	buffs_container.add_child(separator)
	
	# Check for active potions and effects
	var has_any_buff = false
	
	# Fish Slow Potions
	var fish_slow_effect = GlobalVariable.get_fish_slow_effect()
	if fish_slow_effect > 0:
		var buff_label = Label.new()
		buff_label.text = "🐟 Fish Slow: %.0f%%" % (fish_slow_effect * 100)
		buff_label.add_theme_font_size_override("font_size", 14)
		buff_label.add_theme_color_override("font_color", Color.CYAN)
		buffs_container.add_child(buff_label)
		has_any_buff = true
	
	# Player Speed Potions
	var player_speed_effect = GlobalVariable.get_player_speed_effect()
	if player_speed_effect > 0:
		var buff_label = Label.new()
		buff_label.text = "🏃 Player Speed: +%.0f%%" % (player_speed_effect * 100)
		buff_label.add_theme_font_size_override("font_size", 14)
		buff_label.add_theme_color_override("font_color", Color.GREEN)
		buffs_container.add_child(buff_label)
		has_any_buff = true
	
	# Rod Buff Potions
	var rod_buff_effect = GlobalVariable.get_rod_buff_effect()
	if rod_buff_effect > 0:
		var buff_label = Label.new()
		buff_label.text = "🎣 Rod Buff: +%.0f%%" % (rod_buff_effect * 100)
		buff_label.add_theme_font_size_override("font_size", 14)
		buff_label.add_theme_color_override("font_color", Color.ORANGE)
		buffs_container.add_child(buff_label)
		has_any_buff = true
	
	# Legacy potions
	if GlobalVariable.has_slow_potion:
		var buff_label = Label.new()
		buff_label.text = "⏳ Legacy Slow Motion"
		buff_label.add_theme_font_size_override("font_size", 14)
		buff_label.add_theme_color_override("font_color", Color.MAGENTA)
		buffs_container.add_child(buff_label)
		has_any_buff = true
		
	if GlobalVariable.has_speed_potion:
		var buff_label = Label.new()
		buff_label.text = "⚡ Legacy Speed Boost"
		buff_label.add_theme_font_size_override("font_size", 14)
		buff_label.add_theme_color_override("font_color", Color.MAGENTA)
		buffs_container.add_child(buff_label)
		has_any_buff = true
	
	# Show message if no buffs are active
	if not has_any_buff:
		var no_buff_label = Label.new()
		no_buff_label.text = "No active buffs"
		no_buff_label.add_theme_font_size_override("font_size", 14)
		no_buff_label.add_theme_color_override("font_color", Color.GRAY)
		buffs_container.add_child(no_buff_label)

# Helper functions to calculate stat bonuses from various sources
func _get_strength_bonus() -> int:
	var bonus = 0
	# Add logic here for equipment, permanent upgrades, etc.
	# For now, we could add rod-based bonuses
	if GlobalVariable.rod_ref:
		# Example: some rods might give strength bonus
		pass
	return bonus

func _get_speed_bonus() -> int:
	var bonus = 0
	# Speed bonus from player speed potions (converted to stat bonus)
	var speed_effect = GlobalVariable.get_player_speed_effect()
	if speed_effect > 0:
		bonus += int(speed_effect * 5)  # Convert percentage to stat points
	return bonus

func _get_vitality_bonus() -> int:
	var bonus = 0
	# Add logic here for equipment, permanent upgrades, etc.
	return bonus

func _get_luck_bonus() -> int:
	var bonus = 0
	# Rod buff potions could affect luck
	var rod_buff = GlobalVariable.get_rod_buff_effect()
	if rod_buff > 0:
		bonus += int(rod_buff * 3)  # Convert percentage to stat points
	return bonus
