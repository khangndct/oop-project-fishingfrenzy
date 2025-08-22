extends Control
class_name FishCatchPopup

@onready var fish_image = $Background/VBoxContainer/FishImageContainer/FishImage
@onready var fish_name_label = $Background/VBoxContainer/FishNameLabel
@onready var rarity_label = $Background/VBoxContainer/RarityLabel
@onready var background_panel = $Background

signal popup_closed

var can_close: bool = false
var close_timer: Timer

# Rarity colors matching the game's theme
var rarity_colors = {
	FishData.Rarity.COMMON: Color(0.7, 0.7, 0.7, 1),      # Gray
	FishData.Rarity.UNCOMMON: Color(0.4, 1.0, 0.4, 1),    # Green
	FishData.Rarity.RARE: Color(0.4, 0.6, 1.0, 1),        # Blue
	FishData.Rarity.EPIC: Color(0.8, 0.4, 1.0, 1),        # Purple
	FishData.Rarity.LEGENDARY: Color(1.0, 0.8, 0.2, 1)    # Gold
}

func _ready():
	# Ensure popup starts hidden
	visible = false
	# Pause the game when popup is shown
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Create and setup close timer
	close_timer = Timer.new()
	close_timer.wait_time = 0.5
	close_timer.one_shot = true
	close_timer.timeout.connect(_on_close_timer_timeout)
	add_child(close_timer)

func _input(event):
	if visible and can_close and event.is_action_pressed("spaceBar"):
		close_popup()

func _on_close_timer_timeout():
	can_close = true

func show_catch_popup(fish_data: FishData):
	if not fish_data:
		return
	
	# Set fish image
	if fish_data.sprite_texture:
		fish_image.texture = fish_data.sprite_texture
	
	# Set fish name
	fish_name_label.text = fish_data.fish_name
	
	# Set rarity with appropriate color
	var rarity_name = FishData.Rarity.keys()[fish_data.rarity]
	rarity_label.text = rarity_name + " FISH"
	
	# Apply rarity color to both fish name and rarity label
	var rarity_color = rarity_colors.get(fish_data.rarity, Color.WHITE)
	fish_name_label.modulate = rarity_color
	rarity_label.modulate = rarity_color
	
	# Update border color based on rarity
	var style_box = background_panel.get_theme_stylebox("panel") as StyleBoxFlat
	if style_box:
		style_box.border_color = rarity_color
	
	# Show the popup
	visible = true
	
	# Reset close ability and start timer
	can_close = false
	close_timer.start()
	
	# Pause the game
	get_tree().paused = true

func close_popup():
	# Hide the popup
	visible = false
	
	# Resume the game
	get_tree().paused = false
	
	# Emit signal to notify that popup was closed
	popup_closed.emit()
