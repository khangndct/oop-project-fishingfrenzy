extends Control

@onready var back_button = $BackButton
@onready var clear_potions_button = $ClearPotionsButton
@onready var item_list = $ItemList
@onready var item_container = $MainContainer/ItemsPanel/ItemContainer/GridContainer
@onready var confirmation_dialog = $ConfirmationDialog
@onready var confirmation_label = $ConfirmationDialog/Background/VBoxContainer/Label
@onready var purchase_now_button = $ConfirmationDialog/Background/VBoxContainer/HBoxContainer/PurchaseNowButton
@onready var cancel_button = $ConfirmationDialog/Background/VBoxContainer/HBoxContainer/CancelButton

# Money display
@onready var money_label = $MoneyLabel

# Save manager reference
var save_manager

# Track money changes
var last_money_amount = 0

# Item detail panel references
@onready var item_detail_panel = $MainContainer/ItemDetailPanel
@onready var detail_item_image = $MainContainer/ItemDetailPanel/DetailContainer/ItemImage
@onready var detail_item_name = $MainContainer/ItemDetailPanel/DetailContainer/ItemName
@onready var detail_item_description = $MainContainer/ItemDetailPanel/DetailContainer/ItemDescription
@onready var detail_price_label = $MainContainer/ItemDetailPanel/DetailContainer/PriceLabel
@onready var detail_status_label = $MainContainer/ItemDetailPanel/DetailContainer/StatusLabel
@onready var purchase_button = $MainContainer/ItemDetailPanel/DetailContainer/PurchaseButton

var selected_item_index = -1
var selected_item_button = null
var shop_items = [
	{
		"name": "Fish Slow Potion 30%",
		"description": "Slows down all fish by 30% speed. Active for entire fishing session until you return to main menu.",
		"price": 500,
		"id": "fish_slow_potion_30",
		"image_path": "res://Assets/Img/Items/Fish slow potion 30.svg"
	},
	{
		"name": "Fish Slow Potion 50%",
		"description": "Slows down all fish by 50% speed. Active for entire fishing session until you return to main menu.",
		"price": 1000,
		"id": "fish_slow_potion_50",
		"image_path": "res://Assets/Img/Items/Fish slow potion 50.svg"
	},
	{
		"name": "Fish Slow Potion 70%",
		"description": "Slows down all fish by 70% speed. Active for entire fishing session until you return to main menu.",
		"price": 2000,
		"id": "fish_slow_potion_70",
		"image_path": "res://Assets/Img/Items/Fish slow potion 70.svg"
	},
	{
		"name": "Player Speed Potion 20%",
		"description": "Increases player movement speed by 20%. Active for entire fishing session until you return to main menu.",
		"price": 500,
		"id": "player_speed_potion_20",
		"image_path": "res://Assets/Img/Items/Player speed potion 20.svg"
	},
	{
		"name": "Player Speed Potion 30%",
		"description": "Increases player movement speed by 30%. Active for entire fishing session until you return to main menu.",
		"price": 1000,
		"id": "player_speed_potion_30",
		"image_path": "res://Assets/Img/Items/Player speed potion 30.svg"
	},
	{
		"name": "Player Speed Potion 40%",
		"description": "Increases player movement speed by 40%. Active for entire fishing session until you return to main menu.",
		"price": 2000,
		"id": "player_speed_potion_40",
		"image_path": "res://Assets/Img/Items/Player speed potion 40.svg"
	},
	{
		"name": "Rod Buff Potion 30%",
		"description": "Enhances fishing rod performance: 30% faster cast/reel speed and 30% stronger pulling power (less Space key presses needed).",
		"price": 500,
		"id": "rod_buff_potion_30",
		"image_path": "res://Assets/Img/Items/Rod buff potion 30.svg"
	},
	{
		"name": "Rod Buff Potion 50%",
		"description": "Enhances fishing rod performance: 50% faster cast/reel speed and 50% stronger pulling power (less Space key presses needed).",
		"price": 1000,
		"id": "rod_buff_potion_50",
		"image_path": "res://Assets/Img/Items/Rod buff potion 50.svg"
	},
	{
		"name": "Rod Buff Potion 70%",
		"description": "Enhances fishing rod performance: 70% faster cast/reel speed and 70% stronger pulling power (less Space key presses needed).",
		"price": 2000,
		"id": "rod_buff_potion_70",
		"image_path": "res://Assets/Img/Items/Rod buff potion 70.svg"
	},
	{
		"name": "Great Fortune Food",
		"description": "Doubles the spawn rate of RARE, EPIC, and LEGENDARY fish. Active for entire fishing session until you return to main menu.",
		"price": 500,
		"id": "great_fortune_food",
		"image_path": "res://Assets/Img/Items/Great fortune food.svg"
	},
	{
		"name": "Super Fortune Food",
		"description": "Doubles RARE fish spawn rate, triples EPIC and LEGENDARY fish spawn rates. Active for entire fishing session.",
		"price": 1000,
		"id": "super_fortune_food",
		"image_path": "res://Assets/Img/Items/Super fortune food.svg"
	},
	{
		"name": "Ultra Fortune Food",
		"description": "Doubles RARE fish spawn rate, triples EPIC fish spawn rate, and quadruples LEGENDARY fish spawn rate. Active for entire fishing session.",
		"price": 2000,
		"id": "ultra_fortune_food",
		"image_path": "res://Assets/Img/Items/Ultra fortune food.svg"
	},
	{
		"name": "Recovery Energy Food",
		"description": "Instantly restores all energy to maximum. Single use item.",
		"price": 200,
		"id": "recovery_energy_food",
		"image_path": "res://Assets/Img/Items/Recovery energy food.svg"
	},
	{
		"name": "Mighty Energy Food",
		"description": "Reduces energy cost per fish to 1 for the next 50 fish caught. Active until 50 fish are caught.",
		"price": 800,
		"id": "mighty_energy_food",
		"image_path": "res://Assets/Img/Items/Mighty energy food.svg"
	},
	{
		"name": "Grand Energy Food",
		"description": "Restores all energy and reduces energy cost per fish to 1 for the next 100 fish caught. Ultimate energy boost!",
		"price": 1500,
		"id": "grand_energy_food",
		"image_path": "res://Assets/Img/Items/Grand energy food.svg"
	}
]

func _ready():
	# Initialize save manager
	save_manager = preload("res://Common/Utils/SaveManager.gd").new()
	
	# Load game data to ensure sync
	save_manager.load_game()
	
	# Initialize money tracking
	last_money_amount = GlobalVariable.money
	
	setup_ui()
	connect_signals()
	populate_item_grid()
	clear_item_detail()
	update_money_display()

func _process(_delta):
	update_money_display()
	
	# Refresh grid if money changed
	if last_money_amount != GlobalVariable.money:
		last_money_amount = GlobalVariable.money
		populate_item_grid()
		
		# Update detail panel if item is selected
		if selected_item_index >= 0 and selected_item_index < shop_items.size():
			update_item_detail(shop_items[selected_item_index])

func update_money_display():
	if money_label:
		money_label.text = "Your money: $" + str(GlobalVariable.money)

func setup_ui():
	# Set up the confirmation dialog
	confirmation_dialog.hide()
	
	# Setup custom font
	setup_font()
	
	# Setup panel styles for semi-transparent background
	setup_panel_styles()

func setup_font():
	# Load the VCR OSD Mono font
	var font_path = "res://Assets/Font/vcr_osd_mono/VCR_OSD_MONO_1.001.ttf"
	if ResourceLoader.exists(font_path):
		var font = load(font_path)
		
		# Apply font to various UI elements
		if clear_potions_button:
			clear_potions_button.add_theme_font_override("font", font)
		if detail_item_name:
			detail_item_name.add_theme_font_override("font", font)
		if detail_item_description:
			detail_item_description.add_theme_font_override("font", font)
		if detail_price_label:
			detail_price_label.add_theme_font_override("font", font)
		if detail_status_label:
			detail_status_label.add_theme_font_override("font", font)
		if purchase_button:
			purchase_button.add_theme_font_override("font", font)
		if back_button:
			back_button.add_theme_font_override("font", font)
		if confirmation_label:
			confirmation_label.add_theme_font_override("font", font)
		if purchase_now_button:
			purchase_now_button.add_theme_font_override("font", font)
		if cancel_button:
			cancel_button.add_theme_font_override("font", font)

func setup_panel_styles():
	# Create StyleBoxFlat for semi-transparent background
	var items_panel_style = StyleBoxFlat.new()
	items_panel_style.bg_color = Color(0, 0, 0, 0.4)  # Black with 40% opacity
	items_panel_style.border_width_left = 3
	items_panel_style.border_width_right = 3
	items_panel_style.border_width_top = 3
	items_panel_style.border_width_bottom = 3
	items_panel_style.border_color = Color(1, 1, 1, 0.3)  # White border with 30% opacity
	items_panel_style.corner_radius_top_left = 10
	items_panel_style.corner_radius_top_right = 10
	items_panel_style.corner_radius_bottom_left = 10
	items_panel_style.corner_radius_bottom_right = 10
	
	var detail_panel_style = StyleBoxFlat.new()
	detail_panel_style.bg_color = Color(0, 0, 0, 0.4)  # Black with 40% opacity
	detail_panel_style.border_width_left = 2
	detail_panel_style.border_width_right = 2
	detail_panel_style.border_width_top = 2
	detail_panel_style.border_width_bottom = 2
	detail_panel_style.border_color = Color(1, 1, 1, 0.3)  # White border with 30% opacity
	detail_panel_style.corner_radius_top_left = 10
	detail_panel_style.corner_radius_top_right = 10
	detail_panel_style.corner_radius_bottom_left = 10
	detail_panel_style.corner_radius_bottom_right = 10
	
	# Get the panels after the scene is ready
	var items_panel = $MainContainer/ItemsPanel
	var detail_panel = $MainContainer/ItemDetailPanel
	
	# Apply the styles
	items_panel.add_theme_stylebox_override("panel", items_panel_style)
	detail_panel.add_theme_stylebox_override("panel", detail_panel_style)

func connect_signals():
	back_button.pressed.connect(_on_back_button_pressed)
	if clear_potions_button:
		clear_potions_button.pressed.connect(_on_clear_potions_pressed)
	purchase_button.pressed.connect(_on_purchase_button_pressed)
	purchase_now_button.pressed.connect(_on_purchase_now_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)

func populate_item_grid():
	# Clear existing items
	for child in item_container.get_children():
		child.queue_free()
	
	# Reset selection
	selected_item_index = -1
	selected_item_button = null
	clear_item_detail()
	
	for i in range(shop_items.size()):
		var item = shop_items[i]
		var item_button = create_item_button(item, i)
		item_container.add_child(item_button)

func create_item_button(item: Dictionary, index: int) -> Control:
	# Create main container for the item
	var item_control = VBoxContainer.new()
	item_control.custom_minimum_size = Vector2(200, 250)
	
	# Create clickable button
	var button = Button.new()
	button.custom_minimum_size = Vector2(180, 180)
	button.flat = true
	
	# Create a center container to properly center the image
	var center_container = CenterContainer.new()
	center_container.custom_minimum_size = Vector2(180, 180)
	
	# Create image
	var texture_rect = TextureRect.new()
	texture_rect.custom_minimum_size = Vector2(150, 150)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Try to load the image
	if ResourceLoader.exists(item.image_path):
		var texture = load(item.image_path)
		texture_rect.texture = texture
	else:
		# Create a placeholder colored rect if image doesn't exist
		var color_rect = ColorRect.new()
		color_rect.color = Color.CYAN
		color_rect.custom_minimum_size = Vector2(150, 150)
		center_container.add_child(color_rect)
		
		var placeholder_label = Label.new()
		placeholder_label.text = "IMAGE\nNOT FOUND"
		placeholder_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		placeholder_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		# Add font
		var font = load("res://Assets/Font/vcr_osd_mono/VCR_OSD_MONO_1.001.ttf")
		placeholder_label.add_theme_font_override("font", font)
		placeholder_label.add_theme_font_size_override("font_size", 10)
		color_rect.add_child(placeholder_label)
		placeholder_label.anchors_preset = Control.PRESET_FULL_RECT
	
	if texture_rect.texture:
		center_container.add_child(texture_rect)
	
	# Add center container to button
	button.add_child(center_container)
	center_container.anchors_preset = Control.PRESET_FULL_RECT
	
	# Create item name label
	var name_label = Label.new()
	name_label.text = item.name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# Add font
	var vcr_font = load("res://Assets/Font/vcr_osd_mono/VCR_OSD_MONO_1.001.ttf")
	name_label.add_theme_font_override("font", vcr_font)
	name_label.add_theme_font_size_override("font_size", 16)
	
	# Create price label
	var price_label = Label.new()
	var price_text = "Price: Free" if item.price == 0 else "Price: $" + str(item.price)
	price_label.text = price_text
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Add font
	price_label.add_theme_font_override("font", vcr_font)
	price_label.add_theme_font_size_override("font_size", 16)
	
	# Set color based on affordability and ownership
	var is_owned = _is_item_owned_by_id(item.id)
	var can_afford = item.price == 0 or GlobalVariable.money >= item.price
	
	if is_owned:
		price_label.add_theme_color_override("font_color", Color.ORANGE_RED)  # Already owned
	elif can_afford:
		price_label.add_theme_color_override("font_color", Color.LIME_GREEN)  # Can afford
	else:
		price_label.add_theme_color_override("font_color", Color.ORANGE_RED)  # Cannot afford
	
	# Check if player has enough money and set item modulation
	var is_available = _is_item_available_by_id(item.id)
	
	if is_owned:
		item_control.modulate = Color(0.7, 0.7, 0.7, 0.8)  # Gray out if owned
	elif not is_available:
		item_control.modulate = Color(0.7, 0.7, 0.7, 0.8)  # Gray out if not available due to hierarchy
	elif not can_afford:
		item_control.modulate = Color(0.7, 0.7, 0.7, 0.8)  # Gray out if can't afford
	else:
		item_control.modulate = Color.WHITE  # Normal if can afford
	
	# Check if already owned or not enough money
	var status_label = Label.new()
	# Add font
	status_label.add_theme_font_override("font", vcr_font)
	status_label.add_theme_font_size_override("font_size", 12)
	
	if _is_item_owned_by_id(item.id):
		status_label.text = "ALREADY PURCHASED"
		status_label.modulate = Color.GREEN
		button.modulate = Color(0.7, 0.7, 0.7)  # Gray out if owned
	elif not is_available:
		status_label.text = "UPGRADE REQUIRED"
		status_label.modulate = Color.ORANGE
		button.modulate = Color(0.6, 0.6, 0.6)  # Gray out if not available
	elif item.price > 0 and GlobalVariable.money < item.price:
		status_label.text = "NOT ENOUGH MONEY"
		status_label.modulate = Color.RED
		button.modulate = Color(0.6, 0.6, 0.6)  # Gray out if can't afford
	else:
		status_label.text = ""
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Add all components to the container
	item_control.add_child(button)
	item_control.add_child(name_label)
	item_control.add_child(price_label)
	item_control.add_child(status_label)
	
	# Connect button signal
	button.pressed.connect(_on_item_button_pressed.bind(index, button))
	
	return item_control

func _on_item_button_pressed(index: int, button: Button):
	# Reset previous selection
	if selected_item_button:
		selected_item_button.modulate = Color.WHITE if not _is_item_owned(selected_item_index) else Color(0.7, 0.7, 0.7)
	
	# Set new selection
	selected_item_index = index
	selected_item_button = button
	
	var item = shop_items[selected_item_index]
	
	# Check if item is available for purchase
	var is_available = _is_item_available_by_id(item.id)
	
	# Highlight selected item
	if not _is_item_owned(index) and is_available:
		button.modulate = Color.YELLOW
		purchase_button.disabled = false
		purchase_button.text = "Purchase"
	else:
		if _is_item_owned(index):
			purchase_button.disabled = true
			purchase_button.text = "Already Owned"
		elif not is_available:
			purchase_button.disabled = true
			purchase_button.text = "Upgrade Required"
		else:
			purchase_button.disabled = true
			purchase_button.text = "Cannot Purchase"
	
	# Update item detail panel
	update_item_detail(item)

func update_item_detail(item: Dictionary):
	# Update item image
	if ResourceLoader.exists(item.image_path):
		var texture = load(item.image_path)
		detail_item_image.texture = texture
	else:
		detail_item_image.texture = null
	
	# Update item name
	detail_item_name.text = item.name
	
	# Update item description
	detail_item_description.text = item.description
	
	# Update price with new format and colors
	var price_text = "Price: Free" if item.price == 0 else "Price: $" + str(item.price)
	detail_price_label.text = price_text
	
	# Set price color based on affordability and ownership
	var is_owned = _is_item_owned_by_id(item.id)
	var is_available = _is_item_available_by_id(item.id)
	var has_enough_money = item.price == 0 or GlobalVariable.money >= item.price
	
	if is_owned:
		detail_price_label.add_theme_color_override("font_color", Color.ORANGE_RED)
	elif not is_available:
		detail_price_label.add_theme_color_override("font_color", Color.ORANGE)
	elif has_enough_money:
		detail_price_label.add_theme_color_override("font_color", Color.LIME_GREEN)
	else:
		detail_price_label.add_theme_color_override("font_color", Color.ORANGE_RED)
	
	# Update status
	if is_owned:
		detail_status_label.text = "Status: OWNED"
		detail_status_label.modulate = Color.GREEN
		purchase_button.disabled = true
		purchase_button.text = "OWNED"
	elif not is_available:
		detail_status_label.text = "Status: UPGRADE REQUIRED"
		detail_status_label.modulate = Color.ORANGE
		purchase_button.disabled = true
		purchase_button.text = "Upgrade Required"
	elif not has_enough_money:
		detail_status_label.text = "Status: NOT ENOUGH MONEY"
		detail_status_label.modulate = Color.RED
		purchase_button.disabled = true
		purchase_button.text = "Purchase"
	else:
		detail_status_label.text = "Status: AVAILABLE"
		detail_status_label.modulate = Color.LIME_GREEN
		purchase_button.disabled = false
		purchase_button.text = "Purchase"

func clear_item_detail():
	detail_item_image.texture = null
	detail_item_name.text = "Select an item to view details"
	detail_item_description.text = ""
	detail_price_label.text = "Price: "
	detail_status_label.text = "Status: "
	detail_status_label.modulate = Color.WHITE

func _is_item_owned_by_id(item_id: String) -> bool:
	if item_id == "fish_slow_potion_30":
		return GlobalVariable.has_fish_slow_potion_30
	elif item_id == "fish_slow_potion_50":
		return GlobalVariable.has_fish_slow_potion_50
	elif item_id == "fish_slow_potion_70":
		return GlobalVariable.has_fish_slow_potion_70
	elif item_id == "player_speed_potion_20":
		return GlobalVariable.has_player_speed_potion_20
	elif item_id == "player_speed_potion_30":
		return GlobalVariable.has_player_speed_potion_30
	elif item_id == "player_speed_potion_40":
		return GlobalVariable.has_player_speed_potion_40
	elif item_id == "rod_buff_potion_30":
		return GlobalVariable.has_rod_buff_potion_30
	elif item_id == "rod_buff_potion_50":
		return GlobalVariable.has_rod_buff_potion_50
	elif item_id == "rod_buff_potion_70":
		return GlobalVariable.has_rod_buff_potion_70
	elif item_id == "great_fortune_food":
		return GlobalVariable.has_great_fortune_food
	elif item_id == "super_fortune_food":
		return GlobalVariable.has_super_fortune_food
	elif item_id == "ultra_fortune_food":
		return GlobalVariable.has_ultra_fortune_food
	elif item_id == "recovery_energy_food":
		return false  # Single use item, never owned
	elif item_id == "mighty_energy_food":
		return GlobalVariable.has_mighty_energy_food
	elif item_id == "grand_energy_food":
		return GlobalVariable.has_grand_energy_food
	return false

func _is_item_available_by_id(item_id: String) -> bool:
	"""Check if an item can be purchased based on potion hierarchy"""
	# Fish slow potions
	if item_id == "fish_slow_potion_30":
		return not (GlobalVariable.has_fish_slow_potion_50 or GlobalVariable.has_fish_slow_potion_70)
	elif item_id == "fish_slow_potion_50":
		return not GlobalVariable.has_fish_slow_potion_70
	elif item_id == "fish_slow_potion_70":
		return true
	
	# Player speed potions
	elif item_id == "player_speed_potion_20":
		return not (GlobalVariable.has_player_speed_potion_30 or GlobalVariable.has_player_speed_potion_40)
	elif item_id == "player_speed_potion_30":
		return not GlobalVariable.has_player_speed_potion_40
	elif item_id == "player_speed_potion_40":
		return true
	
	# Rod buff potions
	elif item_id == "rod_buff_potion_30":
		return not (GlobalVariable.has_rod_buff_potion_50 or GlobalVariable.has_rod_buff_potion_70)
	elif item_id == "rod_buff_potion_50":
		return not GlobalVariable.has_rod_buff_potion_70
	elif item_id == "rod_buff_potion_70":
		return true
	
	# Fortune foods (hierarchical - higher tier replaces lower)
	elif item_id == "great_fortune_food":
		return not (GlobalVariable.has_super_fortune_food or GlobalVariable.has_ultra_fortune_food)
	elif item_id == "super_fortune_food":
		return not GlobalVariable.has_ultra_fortune_food
	elif item_id == "ultra_fortune_food":
		return true
	
	# Energy foods (can own multiple, except recovery is single use)
	elif item_id == "recovery_energy_food":
		return true  # Always available (single use)
	elif item_id == "mighty_energy_food":
		return not GlobalVariable.has_grand_energy_food  # Can't have both mighty and grand
	elif item_id == "grand_energy_food":
		return true  # Can always upgrade to grand
	
	return true

func _is_item_owned(index: int) -> bool:
	var item = shop_items[index]
	if item.id == "fish_slow_potion_30":
		return GlobalVariable.has_fish_slow_potion_30
	elif item.id == "fish_slow_potion_50":
		return GlobalVariable.has_fish_slow_potion_50
	elif item.id == "fish_slow_potion_70":
		return GlobalVariable.has_fish_slow_potion_70
	elif item.id == "player_speed_potion_20":
		return GlobalVariable.has_player_speed_potion_20
	elif item.id == "player_speed_potion_30":
		return GlobalVariable.has_player_speed_potion_30
	elif item.id == "player_speed_potion_40":
		return GlobalVariable.has_player_speed_potion_40
	elif item.id == "rod_buff_potion_30":
		return GlobalVariable.has_rod_buff_potion_30
	elif item.id == "rod_buff_potion_50":
		return GlobalVariable.has_rod_buff_potion_50
	elif item.id == "rod_buff_potion_70":
		return GlobalVariable.has_rod_buff_potion_70
	return false

func _on_back_button_pressed():
	# Save game before returning to main menu
	if save_manager:
		save_manager.save_game()
	# Return to main menu
	get_tree().change_scene_to_file("res://Scenes/Main/Main.tscn")

func _on_item_selected(_index):
	# This function is no longer used with the new grid layout
	pass

func _on_purchase_button_pressed():
	if selected_item_index >= 0 and selected_item_index < shop_items.size():
		var item = shop_items[selected_item_index]
		
		# Check if already owned
		if item.id == "slow_potion" and GlobalVariable.has_slow_potion:
			return
			
		confirmation_label.text = "Are you sure you want to purchase %s?\n\n%s\n\nPrice: %s" % [
			item.name, 
			item.description, 
			"Free" if item.price == 0 else "$" + str(item.price)
		]
		confirmation_dialog.popup_centered(Vector2i(500, 300))

func _on_purchase_now_pressed():
	if selected_item_index >= 0 and selected_item_index < shop_items.size():
		var item = shop_items[selected_item_index]
		
		# Check if player has enough money (for non-free items)
		if item.price > 0 and GlobalVariable.money < item.price:
			print("Not enough money!")
			confirmation_dialog.hide()
			return
		
		# Deduct money if not free
		if item.price > 0:
			GlobalVariable.money -= item.price
		
		# Add the purchased item to global variables and handle hierarchy
		if item.id == "fish_slow_potion_30":
			GlobalVariable.has_fish_slow_potion_30 = true
		elif item.id == "fish_slow_potion_50":
			# Disable lower tier potion
			GlobalVariable.has_fish_slow_potion_30 = false
			GlobalVariable.has_fish_slow_potion_50 = true
		elif item.id == "fish_slow_potion_70":
			# Disable lower tier potions
			GlobalVariable.has_fish_slow_potion_30 = false
			GlobalVariable.has_fish_slow_potion_50 = false
			GlobalVariable.has_fish_slow_potion_70 = true
		elif item.id == "player_speed_potion_20":
			GlobalVariable.has_player_speed_potion_20 = true
		elif item.id == "player_speed_potion_30":
			# Disable lower tier potion
			GlobalVariable.has_player_speed_potion_20 = false
			GlobalVariable.has_player_speed_potion_30 = true
		elif item.id == "player_speed_potion_40":
			# Disable lower tier potions
			GlobalVariable.has_player_speed_potion_20 = false
			GlobalVariable.has_player_speed_potion_30 = false
			GlobalVariable.has_player_speed_potion_40 = true
		elif item.id == "rod_buff_potion_30":
			GlobalVariable.has_rod_buff_potion_30 = true
		elif item.id == "rod_buff_potion_50":
			# Disable lower tier potion
			GlobalVariable.has_rod_buff_potion_30 = false
			GlobalVariable.has_rod_buff_potion_50 = true
		elif item.id == "rod_buff_potion_70":
			# Disable lower tier potions
			GlobalVariable.has_rod_buff_potion_30 = false
			GlobalVariable.has_rod_buff_potion_50 = false
			GlobalVariable.has_rod_buff_potion_70 = true
		
		# Fortune Foods (hierarchical)
		elif item.id == "great_fortune_food":
			GlobalVariable.has_great_fortune_food = true
		elif item.id == "super_fortune_food":
			# Disable lower tier food
			GlobalVariable.has_great_fortune_food = false
			GlobalVariable.has_super_fortune_food = true
		elif item.id == "ultra_fortune_food":
			# Disable lower tier foods
			GlobalVariable.has_great_fortune_food = false
			GlobalVariable.has_super_fortune_food = false
			GlobalVariable.has_ultra_fortune_food = true
		
		# Energy Foods
		elif item.id == "recovery_energy_food":
			# Single use - restore energy immediately
			if GlobalVariable.player_ref:
				var max_energy = 100 + (GlobalVariable.player_vitality - 1) * 20
				GlobalVariable.player_ref.energy = max_energy
				GlobalVariable.player_energy = max_energy
				print("Energy restored to maximum!")
		elif item.id == "mighty_energy_food":
			# Disable conflicting energy food
			GlobalVariable.has_grand_energy_food = false
			GlobalVariable.grand_energy_fish_count = 0
			GlobalVariable.has_mighty_energy_food = true
			GlobalVariable.mighty_energy_fish_count = 0
		elif item.id == "grand_energy_food":
			# Disable conflicting energy food and restore energy
			GlobalVariable.has_mighty_energy_food = false
			GlobalVariable.mighty_energy_fish_count = 0
			GlobalVariable.has_grand_energy_food = true
			GlobalVariable.grand_energy_fish_count = 0
			# Restore energy immediately
			if GlobalVariable.player_ref:
				var max_energy = 100 + (GlobalVariable.player_vitality - 1) * 20
				GlobalVariable.player_ref.energy = max_energy
				GlobalVariable.player_energy = max_energy
				print("Energy restored and Grand Energy Food activated!")
		
		print("Purchased: ", item.name)
		confirmation_dialog.hide()
		
		# Save game after purchase
		if save_manager:
			save_manager.save_game()
		
		# Refresh the item grid to show updated status
		populate_item_grid()
		
		# Update item detail panel with new status immediately
		update_item_detail(item)
		
		# Keep current item selected so user can see "OWNED" status
		# Don't reset selection here
		
		# Show success message
		_show_purchase_success(item.name)

func _on_cancel_pressed():
	confirmation_dialog.hide()

func _show_purchase_success(item_name):
	# Simple success notification
	print("Successfully purchased: ", item_name)
	# You can add a popup or notification here if needed

func _on_clear_potions_pressed():
	"""Clear all active potion and food effects"""
	GlobalVariable.clear_session_potions()
	print("All potion and food effects cleared!")
	
	# Refresh the item grid to show updated status
	populate_item_grid()
	clear_item_detail()
	
	# Show confirmation message
	print("All active potions and foods have been cleared. You can purchase new ones now.")
