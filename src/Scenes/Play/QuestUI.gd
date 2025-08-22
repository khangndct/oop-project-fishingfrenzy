extends Control

@onready var quest_panel = $QuestPanel
@onready var quest_content = $QuestPanel/QuestContent
@onready var close_button = $QuestPanel/CloseButton

var is_quest_panel_visible = false

func _ready():
	setup_quest_panel()
	quest_panel.visible = false
	if close_button:
		close_button.pressed.connect(_on_close_quest_panel)
		# Prevent button from keeping focus after click
		close_button.focus_mode = Control.FOCUS_NONE

func setup_quest_panel():
	"""Setup quest panel with current level requirements"""
	
	# Clear existing quest items
	for child in quest_content.get_children():
		if child != close_button:
			child.queue_free()
	
	# Add level title
	var level_label = Label.new()
	level_label.text = "Level: " + GlobalVariable.get_level_name(GlobalVariable.current_level)
	level_label.add_theme_font_size_override("font_size", 20)
	level_label.add_theme_color_override("font_color", Color.YELLOW)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quest_content.add_child(level_label)
	
	var separator = HSeparator.new()
	quest_content.add_child(separator)
	
	# Get requirements for current level
	var requirements = GlobalVariable.get_current_level_requirements()
	
	# Total fish quest
	add_quest_item("Catch Fish", GlobalVariable.current_session_fish_caught, requirements.total_fish)
	
	# Rarity-specific quests
	match GlobalVariable.current_level:
		GlobalVariable.GameLevel.EASY:
			add_quest_item("Catch Rare+ Fish", GlobalVariable.current_session_rare_or_better, requirements.rare_or_better)
		GlobalVariable.GameLevel.NORMAL:
			add_quest_item("Catch Epic+ Fish", GlobalVariable.current_session_epic_or_better, requirements.epic_or_better)
		GlobalVariable.GameLevel.HARD:
			add_quest_item("Catch Legendary+ Fish", GlobalVariable.current_session_legendary_or_better, requirements.legendary_or_better)
	
	# Add statistics section
	var stats_separator = HSeparator.new()
	quest_content.add_child(stats_separator)
	
	var stats_label = Label.new()
	stats_label.text = "Session Statistics:"
	stats_label.add_theme_font_size_override("font_size", 16)
	stats_label.add_theme_color_override("font_color", Color.CYAN)
	quest_content.add_child(stats_label)
	
	add_stat_item("Common Fish", GlobalVariable.current_session_common_fish)
	add_stat_item("Uncommon Fish", GlobalVariable.current_session_uncommon_fish)
	add_stat_item("Rare Fish", GlobalVariable.current_session_rare_fish)
	add_stat_item("Epic Fish", GlobalVariable.current_session_epic_fish)
	add_stat_item("Legendary Fish", GlobalVariable.current_session_legendary_fish)
	add_stat_item("Money Earned", "$" + str(GlobalVariable.current_session_money_earned))
	add_stat_item("Potions Used", GlobalVariable.current_session_potions_used)
	add_stat_item("Foods Used", GlobalVariable.current_session_foods_used)
	
	var duration = GlobalVariable.get_session_duration()
	var minutes = int(duration / 60)
	var seconds = int(duration) % 60
	add_stat_item("Time Played", "%02d:%02d" % [minutes, seconds])

func add_quest_item(quest_name: String, current: int, target: int):
	"""Add a quest item to the panel"""
	var quest_item = HBoxContainer.new()
	
	var quest_label = Label.new()
	quest_label.text = quest_name + ":"
	quest_label.custom_minimum_size.x = 200
	quest_item.add_child(quest_label)
	
	var progress_label = Label.new()
	progress_label.text = str(current) + "/" + str(target)
	progress_label.custom_minimum_size.x = 80
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quest_item.add_child(progress_label)
	
	var status_label = Label.new()
	if current >= target:
		status_label.text = "✓"
		status_label.add_theme_color_override("font_color", Color.LIME_GREEN)
	else:
		status_label.text = "✗"
		status_label.add_theme_color_override("font_color", Color.GRAY)
	status_label.custom_minimum_size.x = 30
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quest_item.add_child(status_label)
	
	quest_content.add_child(quest_item)

func add_stat_item(stat_name: String, value):
	"""Add a statistics item to the panel"""
	var stat_item = HBoxContainer.new()
	
	var stat_label = Label.new()
	stat_label.text = stat_name + ":"
	stat_label.custom_minimum_size.x = 200
	stat_item.add_child(stat_label)
	
	var value_label = Label.new()
	value_label.text = str(value)
	value_label.custom_minimum_size.x = 80
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.add_theme_color_override("font_color", Color.WHITE)
	stat_item.add_child(value_label)
	
	quest_content.add_child(stat_item)

func show_quest_panel():
	"""Show the quest panel"""
	setup_quest_panel()  # Refresh content
	quest_panel.visible = true
	is_quest_panel_visible = true

func hide_quest_panel():
	"""Hide the quest panel"""
	quest_panel.visible = false
	is_quest_panel_visible = false

func _on_close_quest_panel():
	"""Close quest panel button pressed"""
	# Update parent's UI state first, then hide
	var play_scene = get_tree().current_scene
	if play_scene and play_scene.has_method("_close_quest_ui"):
		play_scene._close_quest_ui()
	else:
		# Fallback if not called from Play scene
		hide_quest_panel()

func toggle_quest_panel():
	"""Toggle quest panel visibility"""
	if is_quest_panel_visible:
		hide_quest_panel()
	else:
		show_quest_panel()
