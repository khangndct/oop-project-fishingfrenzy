extends Control
class_name InventoryUI

# UI Components
@onready var tab_container: TabContainer = $PanelContainer/VBoxContainer/TabContainer
@onready var potions_tab: Control = $PanelContainer/VBoxContainer/TabContainer/Potions
@onready var food_tab: Control = $PanelContainer/VBoxContainer/TabContainer/Food
@onready var potions_list: VBoxContainer = $PanelContainer/VBoxContainer/TabContainer/Potions/ScrollContainer/VBoxContainer
@onready var food_list: VBoxContainer = $PanelContainer/VBoxContainer/TabContainer/Food/ScrollContainer/VBoxContainer
@onready var confirmation_dialog: AcceptDialog = $ConfirmationDialog
@onready var item_info_label: Label = $ConfirmationDialog/VBoxContainer/ItemInfoLabel
@onready var confirm_button: Button = $ConfirmationDialog/VBoxContainer/HBoxContainer/ConfirmButton
@onready var cancel_button: Button = $ConfirmationDialog/VBoxContainer/HBoxContainer/CancelButton

# State management
var selected_item_type: InventoryManager.ItemType
var inventory_manager: InventoryManager

# Style constants
const ITEM_BUTTON_HEIGHT = 60
const AVAILABLE_COLOR = Color.WHITE
const UNAVAILABLE_COLOR = Color.GRAY

func _ready():
	# Use the global instance (CRITICAL for data persistence!)
	if GlobalVariable.inventory_manager:
		inventory_manager = GlobalVariable.inventory_manager
	else:
		# This should not happen if Main scene properly initialized it
		GlobalVariable.inventory_manager = InventoryManager.get_instance()
		GlobalVariable.add_child(GlobalVariable.inventory_manager)
		inventory_manager = GlobalVariable.inventory_manager
	
	setup_ui()
	refresh_inventory()
	
	# Connect signals
	confirm_button.pressed.connect(_on_confirm_use_item)
	cancel_button.pressed.connect(_on_cancel_use_item)
	
	# Ensure dialog size is set after everything is ready
	call_deferred("_force_dialog_size")

func setup_ui():
	"""Initialize UI components"""
	# Setup tab container
	tab_container.tab_changed.connect(_on_tab_changed)
	
	# Setup confirmation dialog
	confirmation_dialog.hide()
	confirmation_dialog.title = "Use Item"
	confirmation_dialog.size = Vector2(350, 180)  # Smaller, more compact size
	
	# Hide the default OK button since we have custom buttons
	confirmation_dialog.get_ok_button().visible = false
	
	# Critical: Prevent auto-resize behavior that causes first-click stretching
	confirmation_dialog.wrap_controls = true
	# Note: AcceptDialog doesn't have resizable property, use size constraints instead
	
	# Set minimum AND maximum size to force exact dimensions
	confirmation_dialog.min_size = Vector2(350, 180)
	confirmation_dialog.max_size = Vector2(350, 180)  # Force exact size
	
	# Setup item info label to wrap text properly
	item_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item_info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func refresh_inventory():
	"""Refresh the inventory display"""
	
	_refresh_potions_tab()
	_refresh_food_tab()

func _refresh_potions_tab():
	"""Refresh potions tab content - Show potions and fish/player/rod buffs"""
	_clear_container(potions_list)
	
	# Get all potion-type items (speed, slow, rod buffs)
	var potion_types = [
		InventoryManager.ItemType.FISH_SLOW_30,
		InventoryManager.ItemType.FISH_SLOW_50, 
		InventoryManager.ItemType.FISH_SLOW_70,
		InventoryManager.ItemType.PLAYER_SPEED_20,
		InventoryManager.ItemType.PLAYER_SPEED_30,
		InventoryManager.ItemType.PLAYER_SPEED_40,
		InventoryManager.ItemType.ROD_BUFF_30,
		InventoryManager.ItemType.ROD_BUFF_50,
		InventoryManager.ItemType.ROD_BUFF_70
	]
	
	for item_type in potion_types:
		var count = inventory_manager.get_item_count(item_type)
		if count > 0:
			_create_item_button(item_type, count, potions_list)

func _refresh_food_tab():
	"""Refresh food tab content - Show fortune foods and energy foods"""
	_clear_container(food_list)
	
	# Get all food-type items (fortune and energy)
	var food_types = [
		InventoryManager.ItemType.GREAT_FORTUNE,
		InventoryManager.ItemType.SUPER_FORTUNE,
		InventoryManager.ItemType.ULTRA_FORTUNE,
		InventoryManager.ItemType.RECOVERY_ENERGY,
		InventoryManager.ItemType.MIGHTY_ENERGY,
		InventoryManager.ItemType.GRAND_ENERGY
	]
	
	for item_type in food_types:
		var count = inventory_manager.get_item_count(item_type)
		if count > 0:
			_create_item_button(item_type, count, food_list)

func _create_item_button(item_type: InventoryManager.ItemType, count: int, parent: Container):
	"""Create a button for an inventory item"""
	var button = Button.new()
	button.custom_minimum_size.y = ITEM_BUTTON_HEIGHT
	
	# Setup button text and appearance
	var item_name = inventory_manager.get_item_name(item_type)
	var active_effects = inventory_manager.get_active_effects()
	
	button.text = "%s (x%d)" % [item_name, count]
	
	# Show remaining time if active
	if active_effects.has(item_type):
		var remaining_time = active_effects[item_type]
		var minutes = int(remaining_time / 60)
		var seconds = int(remaining_time) % 60
		button.text += "\nActive: %02d:%02d" % [minutes, seconds]
		button.modulate = Color.LIGHT_GREEN
	
	# Special case for Recovery Energy - check if usable
	if item_type == InventoryManager.ItemType.RECOVERY_ENERGY:
		if GlobalVariable.player_energy >= GlobalVariable.get_max_energy():
			button.disabled = true
			button.text += "\n(Energy Full)"
			button.modulate = UNAVAILABLE_COLOR
	
	# Check if item can be used (hierarchy rules)
	elif not _can_use_item_check(item_type):
		button.disabled = true
		var blocking_info = _get_blocking_effect_info(item_type)
		button.text += "\n(Higher effect - %s)" % blocking_info
		button.modulate = UNAVAILABLE_COLOR
	
	# Connect button signal
	button.pressed.connect(_on_item_button_pressed.bind(item_type))
	
	parent.add_child(button)

func _can_use_item_check(item_type: InventoryManager.ItemType) -> bool:
	"""Check if item can be used based on active effects"""
	var hierarchy = _get_item_hierarchy(item_type)
	if hierarchy.is_empty():
		return true
	
	var item_level = hierarchy.find(item_type)
	if item_level == -1:
		return true
	
	var active_effects = inventory_manager.get_active_effects()
	
	# Check if any higher-level item is active
	for i in range(item_level + 1, hierarchy.size()):
		if active_effects.has(hierarchy[i]):
			return false
	
	return true

func _get_blocking_effect_info(item_type: InventoryManager.ItemType) -> String:
	"""Get information about the blocking higher effect"""
	var hierarchy = _get_item_hierarchy(item_type)
	if hierarchy.is_empty():
		return "Unknown effect"
	
	var item_level = hierarchy.find(item_type)
	if item_level == -1:
		return "Unknown effect"
	
	var active_effects = inventory_manager.get_active_effects()
	
	# Find the highest active effect in this hierarchy
	for i in range(hierarchy.size() - 1, item_level, -1):
		var higher_item = hierarchy[i]
		if active_effects.has(higher_item):
			var item_name = inventory_manager.get_item_name(higher_item)
			var remaining = active_effects[higher_item]
			var minutes = int(remaining / 60)
			var seconds = int(remaining) % 60
			return "%s activated - %02d:%02d" % [item_name, minutes, seconds]
	
	return "Higher effect activated"

func _get_item_hierarchy(item_type: InventoryManager.ItemType) -> Array:
	"""Get hierarchy for item type"""
	# Reuse logic from InventoryManager
	var fortune_hierarchy = [
		InventoryManager.ItemType.GREAT_FORTUNE,
		InventoryManager.ItemType.SUPER_FORTUNE,
		InventoryManager.ItemType.ULTRA_FORTUNE
	]
	var energy_hierarchy = [
		InventoryManager.ItemType.RECOVERY_ENERGY,
		InventoryManager.ItemType.MIGHTY_ENERGY,
		InventoryManager.ItemType.GRAND_ENERGY
	]
	var fish_slow_hierarchy = [
		InventoryManager.ItemType.FISH_SLOW_30,
		InventoryManager.ItemType.FISH_SLOW_50,
		InventoryManager.ItemType.FISH_SLOW_70
	]
	var player_speed_hierarchy = [
		InventoryManager.ItemType.PLAYER_SPEED_20,
		InventoryManager.ItemType.PLAYER_SPEED_30,
		InventoryManager.ItemType.PLAYER_SPEED_40
	]
	var rod_buff_hierarchy = [
		InventoryManager.ItemType.ROD_BUFF_30,
		InventoryManager.ItemType.ROD_BUFF_50,
		InventoryManager.ItemType.ROD_BUFF_70
	]
	
	if item_type in fortune_hierarchy:
		return fortune_hierarchy
	elif item_type in energy_hierarchy:
		return energy_hierarchy
	elif item_type in fish_slow_hierarchy:
		return fish_slow_hierarchy
	elif item_type in player_speed_hierarchy:
		return player_speed_hierarchy
	elif item_type in rod_buff_hierarchy:
		return rod_buff_hierarchy
	return []

func _clear_container(container: Container):
	"""Clear all children from a container"""
	for child in container.get_children():
		child.queue_free()

func _on_item_button_pressed(item_type: InventoryManager.ItemType):
	"""Handle item button press"""
	selected_item_type = item_type
	_show_confirmation_dialog(item_type)

func _show_confirmation_dialog(item_type: InventoryManager.ItemType):
	"""Show confirmation dialog for item use"""
	var item_name = inventory_manager.get_item_name(item_type)
	var count = inventory_manager.get_item_count(item_type)
	
	var info_text = "Use %s?\n" % item_name
	info_text += "Available: %d\n" % count
	
	# Special handling for different item types
	if item_type == InventoryManager.ItemType.RECOVERY_ENERGY:
		info_text += "Effect: Restore energy to full\n"
		info_text += "Duration: Instant"
	else:
		info_text += "Effect: Activate buff\n"
		info_text += "Duration: 10 minutes"
		
		var active_effects = inventory_manager.get_active_effects()
		if active_effects.has(item_type):
			var remaining = active_effects[item_type]
			var minutes = int(remaining / 60)
			var seconds = int(remaining) % 60
			info_text += "\nCurrent duration: %02d:%02d" % [minutes, seconds]
			info_text += "\nThis will extend the duration by 10 minutes"
	
	item_info_label.text = info_text
	
	# CRITICAL FIX: Adjust dialog size based on content length
	var dialog_height = 180  # Base height
	if info_text.count("\n") > 4:  # If content has more than 4 lines
		dialog_height = 220  # Increase height for longer content
	
	var dialog_size = Vector2(350, dialog_height)
	
	# Set size BEFORE popup to prevent first-click stretching
	confirmation_dialog.size = dialog_size
	confirmation_dialog.min_size = dialog_size
	confirmation_dialog.max_size = dialog_size
	confirmation_dialog.popup_centered(Vector2i(350, dialog_height))
	
	# Double-ensure size after popup (for extra safety)
	call_deferred("_force_dialog_size_dynamic", dialog_size)

func _force_dialog_size():
	"""Force dialog to maintain fixed size after rendering"""
	confirmation_dialog.size = Vector2(350, 180)

func _force_dialog_size_dynamic(dialog_size: Vector2):
	"""Force dialog to maintain dynamic size after rendering"""
	confirmation_dialog.size = dialog_size
	confirmation_dialog.min_size = dialog_size
	confirmation_dialog.max_size = dialog_size

func _on_confirm_use_item():
	"""Handle confirmation of item use"""
	if inventory_manager.use_item(selected_item_type):
		refresh_inventory()
	
	confirmation_dialog.hide()

func _on_cancel_use_item():
	"""Handle cancellation of item use"""
	confirmation_dialog.hide()

func _on_tab_changed(_tab_index: int):
	"""Handle tab change"""
	refresh_inventory()

# Auto-refresh system
func _process(_delta):
	"""Auto-refresh inventory display periodically"""
	# Refresh every second to update active effect timers
	if Engine.get_process_frames() % 60 == 0:
		refresh_inventory()

func show_inventory():
	"""Show the inventory UI"""
	show()
	refresh_inventory()

func hide_inventory():
	"""Hide the inventory UI"""
	hide()
	confirmation_dialog.hide()
