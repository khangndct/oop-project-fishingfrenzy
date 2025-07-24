extends CanvasLayer

@onready var money_label = $MoneyLabel
@onready var energy_bar = $EnergyBar
var player_ref : Player

func _ready():
	update_money_display()
	# Get reference to player
	player_ref = get_node("../Player")
	if player_ref:
		player_ref.energy_changed.connect(_on_player_energy_changed)
		# Initialize energy bar
		energy_bar.max_value = player_ref.max_energy
		energy_bar.value = player_ref.energy

func _process(_delta):
	update_money_display()

func update_money_display():
	money_label.text = "Money: $" + str(GlobalVariable.money)

func _on_player_energy_changed(new_energy: int):
	energy_bar.value = new_energy
