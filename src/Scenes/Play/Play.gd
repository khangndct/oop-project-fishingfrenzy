extends Node2D

@onready var hud = $HUD
@onready var player_stats_menu = $HUD/PlayerStatsMenu
@onready var stats_button = $HUD/StatsButton

func _ready():
	# Show active potions at start of fishing session
	_show_active_potions()
	
	# Connect HUD signal
	if hud:
		hud.game_ended.connect(_on_game_end)
	
	# Setup player stats menu
	_setup_stats_menu()

func _setup_stats_menu():
	# Connect stats button if it exists
	if stats_button:
		stats_button.pressed.connect(_on_stats_button_pressed)

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
	# Ensure potions are reset when scene is destroyed
	_reset_potions()

func _reset_potions():
	# Reset Fish Slow Potions when leaving play scene
	if GlobalVariable.has_fish_slow_potion_30:
		GlobalVariable.has_fish_slow_potion_30 = false
		print("Fish Slow Potion 30% consumed - purchase again in shop if needed")
	if GlobalVariable.has_fish_slow_potion_50:
		GlobalVariable.has_fish_slow_potion_50 = false
		print("Fish Slow Potion 50% consumed - purchase again in shop if needed")
	if GlobalVariable.has_fish_slow_potion_70:
		GlobalVariable.has_fish_slow_potion_70 = false
		print("Fish Slow Potion 70% consumed - purchase again in shop if needed")
	
	# Reset Player Speed Potions when leaving play scene
	if GlobalVariable.has_player_speed_potion_20:
		GlobalVariable.has_player_speed_potion_20 = false
		print("Player Speed Potion 20% consumed - purchase again in shop if needed")
	if GlobalVariable.has_player_speed_potion_30:
		GlobalVariable.has_player_speed_potion_30 = false
		print("Player Speed Potion 30% consumed - purchase again in shop if needed")
	if GlobalVariable.has_player_speed_potion_40:
		GlobalVariable.has_player_speed_potion_40 = false
		print("Player Speed Potion 40% consumed - purchase again in shop if needed")
	
	# Reset Rod Buff Potions when leaving play scene
	if GlobalVariable.has_rod_buff_potion_30:
		GlobalVariable.has_rod_buff_potion_30 = false
		print("Rod Buff Potion 30% consumed - purchase again in shop if needed")
	if GlobalVariable.has_rod_buff_potion_50:
		GlobalVariable.has_rod_buff_potion_50 = false
		print("Rod Buff Potion 50% consumed - purchase again in shop if needed")
	if GlobalVariable.has_rod_buff_potion_70:
		GlobalVariable.has_rod_buff_potion_70 = false
		print("Rod Buff Potion 70% consumed - purchase again in shop if needed")
	
	# Legacy support
	if GlobalVariable.has_slow_potion:
		GlobalVariable.has_slow_potion = false
		print("Legacy Slow Motion Potion consumed - purchase again in shop if needed")
	if GlobalVariable.has_speed_potion:
		GlobalVariable.has_speed_potion = false
		print("Legacy Speed Potion consumed - purchase again in shop if needed")

func _process(delta):
	pass

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
	if player_stats_menu:
		player_stats_menu.show_menu()

func _input(event):
	"""Handle input events"""
	# Allow ESC key to close stats menu
	if event.is_action_pressed("ui_cancel") and player_stats_menu and player_stats_menu.visible:
		player_stats_menu.hide_menu()
		get_viewport().set_input_as_handled()  # Prevent other UI from handling ESC
