extends CanvasLayer

@onready var money_label = $MoneyLabel
@onready var energy_bar = $EnergyBar
@onready var back_button = $BackButton
var player_ref : Player

signal game_ended

func _ready():
	update_money_display()
	# Get reference to player
	player_ref = get_node("../Player")
	if player_ref:
		player_ref.energy_changed.connect(_on_player_energy_changed)
		# Initialize energy bar
		energy_bar.max_value = player_ref.max_energy
		energy_bar.value = player_ref.energy
	
	# Connect back button
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)

func _process(_delta):
	update_money_display()

func update_money_display():
	money_label.text = "Money: $" + str(GlobalVariable.money)

func _on_player_energy_changed(new_energy: int):
	energy_bar.value = new_energy

func _on_back_button_pressed():
	# Reset potions when back to main (consumed after session)
	if GlobalVariable.has_slow_potion:
		GlobalVariable.has_slow_potion = false
		print("Slow Motion Potion consumed - purchase again in shop if needed")
	if GlobalVariable.has_speed_potion:
		GlobalVariable.has_speed_potion = false
		print("Speed Potion consumed - purchase again in shop if needed")
	
	# Save game before going back
	var save_manager = preload("res://Common/Utils/SaveManager.gd").new()
	save_manager.save_game()
	
	# Emit signal to notify game end
	game_ended.emit()
	# Go back to main menu
	get_tree().change_scene_to_file("res://Scenes/Main/Main.tscn")
