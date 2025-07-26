extends Control

@onready var easy_button: Button = $VBoxContainer/EasyButton
@onready var normal_button: Button = $VBoxContainer/NormalButton  
@onready var hard_button: Button = $VBoxContainer/HardButton
@onready var back_button: Button = $BackButton

func _ready():
	print("LevelSelect _ready() called")
	print("GlobalVariable.unlocked_levels: ", GlobalVariable.unlocked_levels)
	print("GlobalVariable.level_completed: ", GlobalVariable.level_completed)
	
	setup_level_buttons()
	
	# Connect button signals
	easy_button.pressed.connect(_on_easy_selected)
	normal_button.pressed.connect(_on_normal_selected)
	hard_button.pressed.connect(_on_hard_selected)
	back_button.pressed.connect(_on_back_pressed)
	print("LevelSelect setup completed successfully")

func setup_level_buttons():
	"""Setup level buttons based on unlocked levels"""
	print("Setting up level buttons...")
	print("unlocked_levels: ", GlobalVariable.unlocked_levels)
	print("level_completed: ", GlobalVariable.level_completed)
	
	# Easy is always available
	easy_button.disabled = false
	easy_button.text = "Easy Level\n(Catch 50 fish, 5+ Rare)"
	if GlobalVariable.level_completed.has(GlobalVariable.GameLevel.EASY) and GlobalVariable.level_completed[GlobalVariable.GameLevel.EASY]:
		easy_button.text += "\n✓ COMPLETED"
		easy_button.modulate = Color.LIGHT_GREEN
	
	# Normal button
	if GlobalVariable.GameLevel.NORMAL in GlobalVariable.unlocked_levels:
		normal_button.disabled = false
		normal_button.text = "Normal Level\n(Catch 100 fish, 20+ Epic)"
		if GlobalVariable.level_completed.has(GlobalVariable.GameLevel.NORMAL) and GlobalVariable.level_completed[GlobalVariable.GameLevel.NORMAL]:
			normal_button.text += "\n✓ COMPLETED"
			normal_button.modulate = Color.LIGHT_GREEN
	else:
		normal_button.disabled = true
		normal_button.text = "Normal Level\n🔒 LOCKED"
		normal_button.modulate = Color.GRAY
	
	# Hard button
	if GlobalVariable.GameLevel.HARD in GlobalVariable.unlocked_levels:
		hard_button.disabled = false
		hard_button.text = "Hard Level\n(Catch 300 fish, 50+ Legendary)"
		if GlobalVariable.level_completed.has(GlobalVariable.GameLevel.HARD) and GlobalVariable.level_completed[GlobalVariable.GameLevel.HARD]:
			hard_button.text += "\n✓ COMPLETED"
			hard_button.modulate = Color.LIGHT_GREEN
	else:
		hard_button.disabled = true
		hard_button.text = "Hard Level\n🔒 LOCKED"
		hard_button.modulate = Color.GRAY

func _on_easy_selected():
	GlobalVariable.current_level = GlobalVariable.GameLevel.EASY
	start_level()

func _on_normal_selected():
	GlobalVariable.current_level = GlobalVariable.GameLevel.NORMAL
	start_level()

func _on_hard_selected():
	GlobalVariable.current_level = GlobalVariable.GameLevel.HARD
	start_level()

func start_level():
	"""Start the selected level"""
	GlobalVariable.start_level_session()
	get_tree().change_scene_to_file("res://Scenes/Play/Play.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main/Main.tscn")
