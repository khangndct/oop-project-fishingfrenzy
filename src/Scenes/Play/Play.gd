extends Node2D

@onready var hud = $HUD
@onready var player_stats_menu = $HUD/PlayerStatsMenu
@onready var stats_button = $HUD/StatsButton
@onready var quest_ui = $UILayer/QuestUI
@onready var level_completion_screen = $UILayer/LevelCompletionScreen

# Map controller
var map_controller: Map

# Add confirmation dialog
var confirmation_dialog: ConfirmationDialog

# UI state management
var ui_state = {
	"quest_open": false,
	"stats_open": false,
	"confirmation_open": false
}

func _ready():
	# Add to play_scene group for easier access by other nodes
	add_to_group("play_scene")
	
	# Show active potions at start of fishing session
	_show_active_potions()
	
	# Initialize map controller
	_setup_map_controller()
	
	# Connect HUD signal
	if hud:
		hud.game_ended.connect(_on_game_end)
		hud.quest_button_pressed.connect(_on_quest_button_pressed)
		hud.finish_game_pressed.connect(_on_finish_game_pressed)
	
	# Setup player stats menu
	_setup_stats_menu()
	
	# Initialize quest system
	_setup_quest_system()
	
	# Setup confirmation dialog
	_setup_confirmation_dialog()

func _setup_quest_system():
	"""Setup quest UI and level tracking"""
	if level_completion_screen:
		level_completion_screen.visible = false

func _setup_map_controller():
	"""Setup map controller for dynamic backgrounds"""
	# Hide or remove the static background sprite from the scene
	var static_background = $Background
	if static_background:
		static_background.visible = false
		print("Static background hidden - map controller will handle backgrounds")
	
	map_controller = preload("res://Scenes/Play/Map.gd").new()
	map_controller.name = "MapController"
	
	# Configure map settings based on game state
	map_controller.map_change_interval = 120.0  # 2 minutes between potential changes
	map_controller.enable_random_changes = false  # Disable automatic changes - only change when entering play stage
	
	# Connect map signals
	map_controller.map_changed.connect(_on_map_changed)
	map_controller.map_loaded.connect(_on_map_loaded)
	
	# Add to scene (as first child so it renders behind everything)
	add_child(map_controller)
	move_child(map_controller, 0)
	
	# Register with GlobalVariable for global access
	GlobalVariable.set_map_controller_ref(map_controller)
	
	print("Map controller initialized and added to scene")
	
		# Do not trigger initial map change when entering play stage
		# await get_tree().process_frame  # Wait one frame for setup to complete
		# if map_controller:
		#     print("🎮 Triggering initial map change for play stage entry")
		#     map_controller.force_map_change()

func _setup_confirmation_dialog():
	"""Setup confirmation dialog for finish game"""
	confirmation_dialog = ConfirmationDialog.new()
	confirmation_dialog.dialog_text = "Are you sure you want to finish this level early?\nYou will lose progress if you haven't completed all objectives."
	confirmation_dialog.ok_button_text = "Yes, Finish"
	confirmation_dialog.cancel_button_text = "Cancel"
	confirmation_dialog.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	confirmation_dialog.confirmed.connect(_on_confirm_finish_game)
	confirmation_dialog.canceled.connect(_on_cancel_finish_game)
	# Ensure the dialog is handled properly when closed
	confirmation_dialog.close_requested.connect(_on_cancel_finish_game)
	add_child(confirmation_dialog)

func _setup_stats_menu():
	# Connect stats button if it exists
	if stats_button:
		stats_button.pressed.connect(_on_stats_button_pressed)
		# Prevent button from keeping focus after click
		stats_button.focus_mode = Control.FOCUS_NONE

func _show_active_potions():
	# Check Fish Slow Potions (highest level takes priority)
	if GlobalVariable.has_fish_slow_potion_70:
		print("Fish Slow Potion 70% is active this session!")
	elif GlobalVariable.has_fish_slow_potion_50:
		print("Fish Slow Potion 50% is active this session!")
	elif GlobalVariable.has_fish_slow_potion_30:
		print("Fish Slow Potion 30% is active this session!")
	
	# Check Player Speed Potions (highest level takes priority)
	if GlobalVariable.has_player_speed_potion_40:
		print("Player Speed Potion 40% is active this session!")
	elif GlobalVariable.has_player_speed_potion_30:
		print("Player Speed Potion 30% is active this session!")
	elif GlobalVariable.has_player_speed_potion_20:
		print("Player Speed Potion 20% is active this session!")
	
	# Check Rod Buff Potions (highest level takes priority)
	if GlobalVariable.has_rod_buff_potion_70:
		print("Rod Buff Potion 70% is active this session!")
	elif GlobalVariable.has_rod_buff_potion_50:
		print("Rod Buff Potion 50% is active this session!")
	elif GlobalVariable.has_rod_buff_potion_30:
		print("Rod Buff Potion 30% is active this session!")
	
	# Legacy support
	if GlobalVariable.has_slow_potion:
		print("Legacy Slow Motion Potion is active this session!")
	if GlobalVariable.has_speed_potion:
		print("Legacy Speed Potion is active this session!")

func _exit_tree():
	# Don't reset potions - they should persist across sessions
	# User needs to go to shop to buy new potions when they want effects
	
	# Clean up map controller
	if map_controller:
		map_controller.enable_automatic_changes(false)
		print("Map controller cleaned up")
	
	pass

func _reset_potions():
	# REMOVED: Potions should persist across sessions until manually reset
	# This function is kept for compatibility but does nothing
	# Potions will only be consumed when the user decides to reset them manually
	# or when purchasing higher tier potions
	pass

func _process(_delta):
	# Check if level is completed (only if not already shown)
	if not level_completion_screen.visible and GlobalVariable.is_level_completed():
		_show_level_completion(true)

func _on_game_end():
	# Reset potions when back to main (consumed after session)
	_reset_potions()
	print("Fishing session ended")

# Helper functions to get potion effects
func get_fish_slow_effect() -> float:
	# Return the highest fish slow effect (as decimal, e.g., 0.3 for 30%)
	if GlobalVariable.has_fish_slow_potion_70:
		return 0.70
	elif GlobalVariable.has_fish_slow_potion_50:
		return 0.50
	elif GlobalVariable.has_fish_slow_potion_30:
		return 0.30
	elif GlobalVariable.has_slow_potion:  # Legacy support
		return 0.90
	return 0.0

func get_player_speed_effect() -> float:
	# Return the highest player speed effect (as decimal, e.g., 0.2 for 20%)
	if GlobalVariable.has_player_speed_potion_40:
		return 0.40
	elif GlobalVariable.has_player_speed_potion_30:
		return 0.30
	elif GlobalVariable.has_player_speed_potion_20:
		return 0.20
	elif GlobalVariable.has_speed_potion:  # Legacy support
		return 0.20
	return 0.0

func has_any_fish_slow_potion() -> bool:
	return GlobalVariable.has_fish_slow_potion_30 or GlobalVariable.has_fish_slow_potion_50 or GlobalVariable.has_fish_slow_potion_70 or GlobalVariable.has_slow_potion

func has_any_player_speed_potion() -> bool:
	return GlobalVariable.has_player_speed_potion_20 or GlobalVariable.has_player_speed_potion_30 or GlobalVariable.has_player_speed_potion_40 or GlobalVariable.has_speed_potion

func _on_stats_button_pressed():
	"""Handle stats button press - show player stats menu"""
	print("Stats button pressed")
	
	# Close other dialogs first
	if ui_state.quest_open:
		_close_quest_ui()
	if ui_state.confirmation_open:
		_close_confirmation_dialog()
	
	if player_stats_menu:
		print("PlayerStatsMenu exists, checking visibility")
		if ui_state.stats_open:
			print("Hiding menu")
			_close_stats_menu()
		else:
			print("Showing menu")
			_open_stats_menu()
	else:
		print("Warning: player_stats_menu is null!")

func _open_stats_menu():
	"""Open stats menu and update state"""
	player_stats_menu.show_menu()
	ui_state.stats_open = true

func _close_stats_menu():
	"""Close stats menu and update state"""
	player_stats_menu.hide_menu()
	ui_state.stats_open = false

func _on_quest_button_pressed():
	"""Handle quest button press - show quest panel"""
	print("Quest button pressed")
	print("quest_ui exists: ", quest_ui != null)
	
	# Close other dialogs first
	if ui_state.stats_open:
		_close_stats_menu()
	if ui_state.confirmation_open:
		_close_confirmation_dialog()
	
	if quest_ui:
		print("Calling toggle_quest_panel()")
		if ui_state.quest_open:
			_close_quest_ui()
		else:
			_open_quest_ui()
	else:
		print("Warning: quest_ui is null!")

func _open_quest_ui():
	"""Open quest UI and update state"""
	quest_ui.show_quest_panel()
	ui_state.quest_open = true

func _close_quest_ui():
	"""Close quest UI and update state"""
	quest_ui.hide_quest_panel()
	ui_state.quest_open = false

func _on_fish_caught(fish_data: FishData):
	"""Handle fish caught event for quest tracking"""
	# Track fish for quest system
	GlobalVariable.track_fish_caught(fish_data.rarity)
	
	# Randomly trigger map change on special fish catches
	if fish_data.rarity in ["Epic", "Legendary"]:
		var change_chance = randf()
		if change_chance < 0.15:  # 15% chance for rare fish to trigger map change
			print("Rare fish " + str(fish_data.rarity) + " triggered map change!")
			if map_controller:
				map_controller.force_map_change()
	
	# Check if level is completed
	if GlobalVariable.is_level_completed():
		_show_level_completion(true)

# Map event handlers
func _on_map_changed(map_name: String):
	"""Handle map change events"""
	print("Current map changed to: " + map_name)
	
	# Update global map effects cache
	GlobalVariable.update_current_map_effects()
	
	# Show map change notification
	_show_map_change_notification(map_name)

func _on_map_loaded(map_texture: Texture2D):
	"""Handle map texture loaded events"""
	print("New map texture loaded successfully")
	
	# Update global map effects cache
	GlobalVariable.update_current_map_effects()
	
	# Could trigger visual effects or adjust lighting here

func _show_map_change_notification(map_name: String):
	"""Show a brief notification when map changes"""
	print("Map Environment: " + map_name)
	
	# Get current map effects for display
	var effects = GlobalVariable.get_current_map_effects_summary()
	if effects.has("player_effects"):
		var player_effects = effects.player_effects
		print("Player Effects:")
		if player_effects.movement_speed_modifier != 1.0:
			var change = (player_effects.movement_speed_modifier - 1.0) * 100
			print("  Movement Speed: " + ("+" if change >= 0 else "") + str(int(change)) + "%")
		if player_effects.energy_cost_modifier != 1.0:
			var change = (1.0 - player_effects.energy_cost_modifier) * 100
			print("  Energy Efficiency: " + ("+" if change >= 0 else "") + str(int(change)) + "%")
		if player_effects.pull_strength_modifier != 1.0:
			var change = (player_effects.pull_strength_modifier - 1.0) * 100
			print("  Pull Strength: " + ("+" if change >= 0 else "") + str(int(change)) + "%")
	
	if effects.has("fish_effects"):
		var fish_effects = effects.fish_effects
		print("Fish Behavior:")
		if fish_effects.speed_modifier != 1.0:
			var change = (fish_effects.speed_modifier - 1.0) * 100
			print("  Fish Speed: " + ("+" if change >= 0 else "") + str(int(change)) + "%")
		if fish_effects.escape_chance_modifier != 1.0:
			var change = (fish_effects.escape_chance_modifier - 1.0) * 100
			print("  Escape Chance: " + ("+" if change >= 0 else "") + str(int(change)) + "%")

# Map control functions for external use
func get_current_map_info() -> Dictionary:
	"""Get current map information"""
	if map_controller:
		return map_controller.get_current_map_info()
	return {}

func force_map_change():
	"""Force an immediate map change"""
	if map_controller:
		return map_controller.force_map_change()
	return false

func set_map_change_enabled(enabled: bool):
	"""Enable or disable automatic map changes"""
	if map_controller:
		map_controller.enable_automatic_changes(enabled)

func adjust_map_probabilities_for_level():
	"""Adjust map probabilities based on current level/progress"""
	if not map_controller:
		return
	
	# Example: Adjust based on player stats or level progression
	var player_level = 1
	if GlobalVariable.has("player_level"):
		player_level = GlobalVariable.player_level
	
	if map_controller.has_method("_on_player_level_changed"):
		map_controller._on_player_level_changed(player_level)

func _on_finish_game_pressed():
	"""Handle finish game button press (early exit)"""
	print("Finish game button pressed, showing confirmation dialog")
	
	# Safety check - ensure node is still in tree
	if not is_inside_tree():
		print("Node is not in tree, cannot show confirmation dialog")
		return
	
	# Close other dialogs first
	if ui_state.stats_open:
		_close_stats_menu()
	if ui_state.quest_open:
		_close_quest_ui()
	
	if confirmation_dialog and not ui_state.confirmation_open:
		# Pause game while showing dialog
		get_tree().paused = true
		confirmation_dialog.popup_centered()
		ui_state.confirmation_open = true

func _on_confirm_finish_game():
	"""Handle confirmed finish game action"""
	print("Finish game confirmed by user")
	_close_confirmation_dialog()
	
	# Show level completion screen (game is finished early, so not completed)
	_show_level_completion(false)

func _on_cancel_finish_game():
	"""Handle canceled finish game action"""
	print("Finish game canceled by user")
	_close_confirmation_dialog()

func _close_confirmation_dialog():
	"""Close confirmation dialog and update state"""
	# Safety check - ensure node is still in tree
	if is_inside_tree():
		# Unpause the game
		get_tree().paused = false
	ui_state.confirmation_open = false

func _show_level_completion(completed: bool):
	"""Show level completion screen"""
	if level_completion_screen:
		level_completion_screen.show_completion_screen(completed)

func _input(event):
	"""Handle input events"""
	# Allow ESC key to close any open UI
	if event.is_action_pressed("ui_cancel"):
		var handled = false
		
		# Close stats menu if open
		if ui_state.stats_open:
			_close_stats_menu()
			handled = true
		
		# Close quest UI if open
		if ui_state.quest_open:
			_close_quest_ui()
			handled = true
		
		# Close confirmation dialog if open
		if ui_state.confirmation_open:
			_close_confirmation_dialog()
			handled = true
		
		# Prevent other handlers from processing this event if we handled it
		if handled:
			get_viewport().set_input_as_handled()
	
	# DEBUG: Add manual map change trigger with M key ONLY
	if event is InputEventKey and event.pressed and event.keycode == KEY_M:
		print("DEBUG: Manual map change triggered!")
		if map_controller:
			var result = map_controller.force_map_change()
			print("Force map change result: " + str(result))
		else:
			print("ERROR: map_controller is null!")
	
	# Prevent space bar from triggering UI buttons when they're not supposed to
	if event.is_action_pressed("spaceBar") or event.is_action_pressed("ui_accept"):
		# If any UI dialog is open, prevent space/enter from affecting game
		if ui_state.stats_open or ui_state.quest_open or ui_state.confirmation_open:
			# Allow space/enter only for confirmation dialog
			if not ui_state.confirmation_open:
				get_viewport().set_input_as_handled()
