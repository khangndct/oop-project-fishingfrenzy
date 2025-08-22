extends CanvasLayer

@onready var money_label = $MoneyLabel
@onready var energy_bar = $EnergyBar
@onready var back_button = $BackButton
@onready var fish_catch_popup = $FishCatchPopup
@onready var quest_button = $QuestButton
@onready var inventory_button = $InventoryButton
var player_ref : Player

signal game_ended
signal quest_button_pressed
signal inventory_button_pressed
signal finish_game_pressed

func _ready():
	# Set global reference to HUD
	GlobalVariable.hud_ref = self
	
	update_money_display()
	# Get reference to player
	player_ref = get_node("../Player")
	if player_ref:
		player_ref.energy_changed.connect(_on_player_energy_changed)
		# Initialize energy bar
		energy_bar.max_value = player_ref.max_energy
		energy_bar.value = player_ref.energy
	
	# Connect buttons
	if back_button:
		back_button.text = "Finish Game"  # Change text
		back_button.pressed.connect(_on_finish_game_pressed)
		# Prevent button from keeping focus after click
		back_button.focus_mode = Control.FOCUS_NONE
	
	# Connect catch popup signal
	if fish_catch_popup:
		fish_catch_popup.popup_closed.connect(_on_fish_catch_popup_closed)
	
	if quest_button:
		quest_button.pressed.connect(_on_quest_button_pressed)
		# Prevent button from keeping focus after click
		quest_button.focus_mode = Control.FOCUS_NONE
	
	if inventory_button:
		inventory_button.pressed.connect(_on_inventory_button_pressed)
		# Prevent button from keeping focus after click
		inventory_button.focus_mode = Control.FOCUS_NONE

func _process(_delta):
	update_money_display()
	# Also sync energy bar with GlobalVariable in case of discrepancies
	_sync_energy_display()

func update_money_display():
	money_label.text = "Money: $" + str(GlobalVariable.money)

func _sync_energy_display():
	"""Sync energy bar with GlobalVariable.player_energy"""
	if energy_bar and GlobalVariable.player_energy != energy_bar.value:
		energy_bar.value = GlobalVariable.player_energy
		# Also update max value in case vitality changed
		energy_bar.max_value = GlobalVariable.get_max_energy()

func _on_player_energy_changed(new_energy: int):
	energy_bar.value = new_energy

func _on_quest_button_pressed():
	"""Handle quest button press"""
	quest_button_pressed.emit()

func _on_inventory_button_pressed():
	"""Handle inventory button press"""
	inventory_button_pressed.emit()

func _on_finish_game_pressed():
	"""Handle finish game button press (early exit from level)"""
	finish_game_pressed.emit()

func _on_back_button_pressed():
	"""This function handles the actual scene change when game is finished"""
	
	# Reset potions when back to main (consumed after session)
	if GlobalVariable.has_slow_potion:
		GlobalVariable.has_slow_potion = false
	if GlobalVariable.has_speed_potion:
		GlobalVariable.has_speed_potion = false
	
	# Save game before going back
	var save_manager = preload("res://Common/Utils/SaveManager.gd").new()
	save_manager.save_game()
	
	# Emit signal to notify game end
	game_ended.emit()
	# Go back to main menu
	get_tree().change_scene_to_file("res://Scenes/Main/Main.tscn")

func show_fish_catch_popup(fish_data: FishData):
	"""Show the congratulations popup for a caught fish"""
	if fish_catch_popup and fish_data:
		fish_catch_popup.show_catch_popup(fish_data)

func _on_fish_catch_popup_closed():
	"""Handle when the fish catch popup is closed"""
	pass
