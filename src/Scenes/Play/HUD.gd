extends CanvasLayer

@onready var money_label = $MoneyLabel
@onready var energy_bar = $EnergyBar
@onready var back_button = $BackButton
@onready var quest_button = $QuestButton
var player_ref : Player

signal game_ended
signal quest_button_pressed
signal finish_game_pressed

func _ready():
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
	
	if quest_button:
		quest_button.pressed.connect(_on_quest_button_pressed)
		# Prevent button from keeping focus after click
		quest_button.focus_mode = Control.FOCUS_NONE

func _process(_delta):
	update_money_display()

func update_money_display():
	money_label.text = "Money: $" + str(GlobalVariable.money)

func _on_player_energy_changed(new_energy: int):
	energy_bar.value = new_energy

func _on_quest_button_pressed():
	"""Handle quest button press"""
	quest_button_pressed.emit()

func _on_finish_game_pressed():
	"""Handle finish game button press (early exit from level)"""
	finish_game_pressed.emit()

func _on_back_button_pressed():
	# This function is kept for compatibility but renamed functionality
	_on_finish_game_pressed()
