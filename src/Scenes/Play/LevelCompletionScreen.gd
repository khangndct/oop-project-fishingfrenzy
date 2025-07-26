extends Control

@onready var title_label = $Panel/VBoxContainer/TitleLabel
@onready var stats_container = $Panel/VBoxContainer/StatsContainer
@onready var continue_button = $Panel/VBoxContainer/ContinueButton

var level_completed: bool = false

func _ready():
	continue_button.pressed.connect(_on_continue_pressed)

func show_completion_screen(completed: bool = false):
	"""Show the level completion screen with stats"""
	level_completed = completed
	
	# Pause the game
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Set title based on completion
	if completed:
		title_label.text = "LEVEL COMPLETED!"
		title_label.add_theme_color_override("font_color", Color.LIME_GREEN)
		continue_button.text = "Continue to Level Select"
	else:
		title_label.text = "LEVEL FINISHED"
		title_label.add_theme_color_override("font_color", Color.YELLOW)
		continue_button.text = "Return to Level Select"
	
	# Clear existing stats
	for child in stats_container.get_children():
		child.queue_free()
	
	# Add statistics
	add_stat_line("Total Fish Caught:", str(GlobalVariable.current_session_fish_caught))
	add_stat_line("Common Fish:", str(GlobalVariable.current_session_common_fish))
	add_stat_line("Uncommon Fish:", str(GlobalVariable.current_session_uncommon_fish))
	add_stat_line("Rare Fish:", str(GlobalVariable.current_session_rare_fish))
	add_stat_line("Epic Fish:", str(GlobalVariable.current_session_epic_fish))
	add_stat_line("Legendary Fish:", str(GlobalVariable.current_session_legendary_fish))
	
	add_separator()
	
	add_stat_line("Money Earned:", "$" + str(GlobalVariable.current_session_money_earned))
	add_stat_line("Potions Used:", str(GlobalVariable.current_session_potions_used))
	add_stat_line("Foods Used:", str(GlobalVariable.current_session_foods_used))
	
	add_separator()
	
	var duration = GlobalVariable.get_session_duration()
	var minutes = int(duration / 60)
	var seconds = int(duration) % 60
	add_stat_line("Time Played:", "%02d:%02d" % [minutes, seconds])
	
	# Show level requirements
	add_separator()
	var level_label = Label.new()
	level_label.text = "Level Requirements:"
	level_label.add_theme_font_size_override("font_size", 16)
	level_label.add_theme_color_override("font_color", Color.CYAN)
	stats_container.add_child(level_label)
	
	var requirements = GlobalVariable.get_current_level_requirements()
	add_requirement_line("Total Fish:", GlobalVariable.current_session_fish_caught, requirements.total_fish)
	
	match GlobalVariable.current_level:
		GlobalVariable.GameLevel.EASY:
			add_requirement_line("Rare+ Fish:", GlobalVariable.current_session_rare_or_better, requirements.rare_or_better)
		GlobalVariable.GameLevel.NORMAL:
			add_requirement_line("Epic+ Fish:", GlobalVariable.current_session_epic_or_better, requirements.epic_or_better)
		GlobalVariable.GameLevel.HARD:
			add_requirement_line("Legendary+ Fish:", GlobalVariable.current_session_legendary_or_better, requirements.legendary_or_better)
	
	self.visible = true

func add_stat_line(label_text: String, value_text: String):
	"""Add a statistics line"""
	var hbox = HBoxContainer.new()
	
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 150
	hbox.add_child(label)
	
	var value = Label.new()
	value.text = value_text
	value.add_theme_color_override("font_color", Color.WHITE)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hbox.add_child(value)
	
	stats_container.add_child(hbox)

func add_requirement_line(label_text: String, current: int, required: int):
	"""Add a requirement line with completion status"""
	var hbox = HBoxContainer.new()
	
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 150
	hbox.add_child(label)
	
	var progress = Label.new()
	progress.text = str(current) + "/" + str(required)
	progress.custom_minimum_size.x = 80
	progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if current >= required:
		progress.add_theme_color_override("font_color", Color.LIME_GREEN)
	else:
		progress.add_theme_color_override("font_color", Color.RED)
	hbox.add_child(progress)
	
	var status = Label.new()
	if current >= required:
		status.text = "✓"
		status.add_theme_color_override("font_color", Color.LIME_GREEN)
	else:
		status.text = "✗"
		status.add_theme_color_override("font_color", Color.RED)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hbox.add_child(status)
	
	stats_container.add_child(hbox)

func add_separator():
	"""Add a visual separator"""
	var separator = HSeparator.new()
	stats_container.add_child(separator)

func _on_continue_pressed():
	"""Handle continue button press"""
	print("Continue button pressed")
	
	# Unpause the game first
	get_tree().paused = false
	
	if level_completed:
		# Mark level as completed and unlock next level
		print("Level was completed, unlocking next level")
		GlobalVariable.complete_current_level()
	else:
		print("Level was finished early, no progression")
	
	# Save progress and return to level select
	var save_manager = preload("res://Common/Utils/SaveManager.gd").new()
	save_manager.save_game()
	print("Saved game, returning to level select")
	
	# Double check scene file exists
	if ResourceLoader.exists("res://Scenes/LevelSelect/LevelSelect.tscn"):
		print("LevelSelect.tscn found, changing scene")
		get_tree().change_scene_to_file("res://Scenes/LevelSelect/LevelSelect.tscn")
	else:
		print("ERROR: LevelSelect.tscn not found! Falling back to Main menu")
		get_tree().change_scene_to_file("res://Scenes/Main/Main.tscn")
