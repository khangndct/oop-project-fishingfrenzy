extends Node
class_name InventoryManager

# Signals for real-time effect updates
signal effect_activated(item_type: ItemType)
signal effect_expired(item_type: ItemType)
signal energy_restored()

# Singleton Pattern implementation
static var _instance: InventoryManager = null

# Enums for type safety and organization
enum ItemType {
	# Potions (Fortune Effects)
	GREAT_FORTUNE,      # +10% fortune
	SUPER_FORTUNE,      # +20% fortune  
	ULTRA_FORTUNE,      # +30% fortune
	
	# Food (Energy & Speed Effects)
	RECOVERY_ENERGY,    # Restore energy to full (instant)
	MIGHTY_ENERGY,      # +50% energy regen (10 min)
	GRAND_ENERGY,       # +100% energy regen (10 min)
	
	FISH_SLOW_30,       # Fish 30% slower (10 min)
	FISH_SLOW_50,       # Fish 50% slower (10 min)
	FISH_SLOW_70,       # Fish 70% slower (10 min)
	
	PLAYER_SPEED_20,    # Player 20% faster (10 min)
	PLAYER_SPEED_30,    # Player 30% faster (10 min)
	PLAYER_SPEED_40,    # Player 40% faster (10 min)
	
	ROD_BUFF_30,        # Rod 30% stronger (10 min)
	ROD_BUFF_50,        # Rod 50% stronger (10 min)
	ROD_BUFF_70         # Rod 70% stronger (10 min)
}

enum ItemCategory {
	POTION,
	FOOD
}

# Core inventory data
var inventory: Dictionary = {}  # ItemType -> int (count)
var active_effects: Dictionary = {}  # ItemType -> float (remaining time)

# Item metadata
var item_names: Dictionary = {
	ItemType.GREAT_FORTUNE: "Great Fortune Potion",
	ItemType.SUPER_FORTUNE: "Super Fortune Potion", 
	ItemType.ULTRA_FORTUNE: "Ultra Fortune Potion",
	ItemType.RECOVERY_ENERGY: "Recovery Energy Food",
	ItemType.MIGHTY_ENERGY: "Mighty Energy Food",
	ItemType.GRAND_ENERGY: "Grand Energy Food",
	ItemType.FISH_SLOW_30: "Fish Slow 30% Food",
	ItemType.FISH_SLOW_50: "Fish Slow 50% Food",
	ItemType.FISH_SLOW_70: "Fish Slow 70% Food",
	ItemType.PLAYER_SPEED_20: "Player Speed 20% Food",
	ItemType.PLAYER_SPEED_30: "Player Speed 30% Food",
	ItemType.PLAYER_SPEED_40: "Player Speed 40% Food",
	ItemType.ROD_BUFF_30: "Rod Buff 30% Food",
	ItemType.ROD_BUFF_50: "Rod Buff 50% Food",
	ItemType.ROD_BUFF_70: "Rod Buff 70% Food"
}

var item_categories: Dictionary = {
	ItemType.GREAT_FORTUNE: ItemCategory.POTION,
	ItemType.SUPER_FORTUNE: ItemCategory.POTION,
	ItemType.ULTRA_FORTUNE: ItemCategory.POTION,
	ItemType.RECOVERY_ENERGY: ItemCategory.FOOD,
	ItemType.MIGHTY_ENERGY: ItemCategory.FOOD,
	ItemType.GRAND_ENERGY: ItemCategory.FOOD,
	ItemType.FISH_SLOW_30: ItemCategory.FOOD,
	ItemType.FISH_SLOW_50: ItemCategory.FOOD,
	ItemType.FISH_SLOW_70: ItemCategory.FOOD,
	ItemType.PLAYER_SPEED_20: ItemCategory.FOOD,
	ItemType.PLAYER_SPEED_30: ItemCategory.FOOD,
	ItemType.PLAYER_SPEED_40: ItemCategory.FOOD,
	ItemType.ROD_BUFF_30: ItemCategory.FOOD,
	ItemType.ROD_BUFF_50: ItemCategory.FOOD,
	ItemType.ROD_BUFF_70: ItemCategory.FOOD
}

# Effect duration (10 minutes = 600 seconds)
const EFFECT_DURATION = 600.0

# Singleton Pattern implementation
static func get_instance() -> InventoryManager:
	if _instance == null:
		_instance = InventoryManager.new()
		_instance.name = "InventoryManager"
		# Prevent auto-deletion during scene changes
		_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	return _instance

func _ready():
	# Initialize inventory
	_initialize_inventory()
	
	# Set up timer for effect management
	set_process(true)

func _initialize_inventory():
	"""Initialize all item counts to 0"""
	for item_type in ItemType.values():
		inventory[item_type] = 0

# Encapsulation: Public interface methods
func add_item(item_type: ItemType, count: int = 1) -> bool:
	"""Add items to inventory with validation"""
	if not _is_valid_item_type(item_type) or count <= 0:
		return false
	
	inventory[item_type] = inventory.get(item_type, 0) + count
	return true

func remove_item(item_type: ItemType, count: int = 1) -> bool:
	"""Remove items from inventory with validation"""
	if not _is_valid_item_type(item_type) or count <= 0:
		return false
	
	var current_count = inventory.get(item_type, 0)
	if current_count < count:
		# Remove all if requested count exceeds available
		inventory[item_type] = 0
		return true
	
	inventory[item_type] = current_count - count
	return true

func use_item(item_type: ItemType) -> bool:
	"""Use an item with comprehensive validation"""
	if not _can_use_item(item_type):
		return false
	
	# Consume the item
	inventory[item_type] -= 1
	
	# Apply the effect
	_apply_item_effect(item_type)
	
	return true

func get_item_count(item_type: ItemType) -> int:
	"""Get count of specific item"""
	return inventory.get(item_type, 0)

func get_item_name(item_type: ItemType) -> String:
	"""Get display name of item"""
	return item_names.get(item_type, "Unknown Item")

func get_active_effects() -> Dictionary:
	"""Get all currently active effects"""
	return active_effects.duplicate()

func get_available_items_by_category(category: ItemCategory) -> Dictionary:
	"""Get all available items filtered by category"""
	var filtered_items = {}
	
	for item_type in inventory:
		if item_categories.get(item_type) == category and inventory[item_type] > 0:
			filtered_items[item_type] = inventory[item_type]
	
	return filtered_items

# Template Method Pattern: Defines algorithm structure for item usage
func _can_use_item(item_type: ItemType) -> bool:
	"""Template method for item usage validation"""
	return _has_item_in_inventory(item_type) and _passes_hierarchy_check(item_type) and _passes_special_conditions(item_type)

func _has_item_in_inventory(item_type: ItemType) -> bool:
	"""Check if item is available in inventory"""
	return inventory.get(item_type, 0) > 0

func _passes_hierarchy_check(item_type: ItemType) -> bool:
	"""Check hierarchy restrictions (no downgrades allowed)"""
	var hierarchy = _get_item_hierarchy(item_type)
	if hierarchy.is_empty():
		return true
	
	var item_level = hierarchy.find(item_type)
	if item_level == -1:
		return true
	
	# Check if any higher-level item is active
	for i in range(item_level + 1, hierarchy.size()):
		if active_effects.has(hierarchy[i]):
			return false
	
	return true

func _passes_special_conditions(item_type: ItemType) -> bool:
	"""Check special conditions (e.g., Recovery Energy when energy is full)"""
	if item_type == ItemType.RECOVERY_ENERGY:
		if GlobalVariable.player_energy >= GlobalVariable.get_max_energy():
			return false
	
	return true

# Strategy Pattern: Different strategies for different item effects
func _apply_item_effect(item_type: ItemType):
	"""Apply the appropriate effect based on item type"""
	match item_type:
		ItemType.RECOVERY_ENERGY:
			_apply_instant_energy_recovery()
		ItemType.GREAT_FORTUNE, ItemType.SUPER_FORTUNE, ItemType.ULTRA_FORTUNE:
			_apply_duration_effect(item_type)
		ItemType.MIGHTY_ENERGY, ItemType.GRAND_ENERGY:
			_apply_duration_effect(item_type)
		ItemType.FISH_SLOW_30, ItemType.FISH_SLOW_50, ItemType.FISH_SLOW_70:
			_apply_duration_effect(item_type)
		ItemType.PLAYER_SPEED_20, ItemType.PLAYER_SPEED_30, ItemType.PLAYER_SPEED_40:
			_apply_duration_effect(item_type)
		ItemType.ROD_BUFF_30, ItemType.ROD_BUFF_50, ItemType.ROD_BUFF_70:
			_apply_duration_effect(item_type)

func _apply_instant_energy_recovery():
	"""Strategy for instant energy recovery"""
	var max_energy = GlobalVariable.get_max_energy()
	GlobalVariable.player_energy = max_energy
	
	# Also update the player instance if it exists (using setter to trigger signal)
	if GlobalVariable.player_ref:
		GlobalVariable.player_ref.set_energy(max_energy)
	
	# Emit signal for immediate UI/effect updates
	energy_restored.emit()

func _apply_duration_effect(item_type: ItemType):
	"""Strategy for duration-based effects"""
	var was_active = active_effects.has(item_type)
	
	if was_active:
		# Extend existing effect
		active_effects[item_type] += EFFECT_DURATION
	else:
		# Start new effect
		active_effects[item_type] = EFFECT_DURATION
		
		# Emit signal for immediate effect activation
		effect_activated.emit(item_type)

# Polymorphism: Different hierarchy behaviors for different item types
func _get_item_hierarchy(item_type: ItemType) -> Array:
	"""Get the hierarchy array for the given item type"""
	var fortune_hierarchy = [ItemType.GREAT_FORTUNE, ItemType.SUPER_FORTUNE, ItemType.ULTRA_FORTUNE]
	var energy_hierarchy = [ItemType.RECOVERY_ENERGY, ItemType.MIGHTY_ENERGY, ItemType.GRAND_ENERGY]
	var fish_slow_hierarchy = [ItemType.FISH_SLOW_30, ItemType.FISH_SLOW_50, ItemType.FISH_SLOW_70]
	var player_speed_hierarchy = [ItemType.PLAYER_SPEED_20, ItemType.PLAYER_SPEED_30, ItemType.PLAYER_SPEED_40]
	var rod_buff_hierarchy = [ItemType.ROD_BUFF_30, ItemType.ROD_BUFF_50, ItemType.ROD_BUFF_70]
	
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

# Private validation
func _is_valid_item_type(item_type: ItemType) -> bool:
	"""Validate item type"""
	return item_type in ItemType.values()

# Effect management (Observer Pattern implementation)
func _process(delta):
	"""Update active effects and notify observers"""
	var effects_to_remove = []
	
	for item_type in active_effects:
		active_effects[item_type] -= delta
		if active_effects[item_type] <= 0:
			effects_to_remove.append(item_type)
	
	# Remove expired effects and emit signals
	for item_type in effects_to_remove:
		active_effects.erase(item_type)
		effect_expired.emit(item_type)

# Public utility methods for game integration
func get_fortune_multiplier() -> float:
	"""Get current fortune multiplier from active effects"""
	var multiplier = 1.0
	
	if active_effects.has(ItemType.ULTRA_FORTUNE):
		multiplier += 0.30
	elif active_effects.has(ItemType.SUPER_FORTUNE):
		multiplier += 0.20
	elif active_effects.has(ItemType.GREAT_FORTUNE):
		multiplier += 0.10
	
	return multiplier

func get_energy_regen_multiplier() -> float:
	"""Get current energy regeneration multiplier"""
	var multiplier = 1.0
	
	if active_effects.has(ItemType.GRAND_ENERGY):
		multiplier += 1.0  # +100%
	elif active_effects.has(ItemType.MIGHTY_ENERGY):
		multiplier += 0.5  # +50%
	
	return multiplier

func get_rod_buff_effect() -> float:
	"""Get current rod buff effect (0.0 = no effect, 0.7 = 70% faster/stronger)"""
	if active_effects.has(ItemType.ROD_BUFF_70):
		return 0.7
	elif active_effects.has(ItemType.ROD_BUFF_50):
		return 0.5
	elif active_effects.has(ItemType.ROD_BUFF_30):
		return 0.3
	
	return 0.0

func get_player_speed_effect() -> float:
	"""Get current player speed effect (0.0 = no effect, 0.4 = 40% faster)"""
	if active_effects.has(ItemType.PLAYER_SPEED_40):
		return 0.4
	elif active_effects.has(ItemType.PLAYER_SPEED_30):
		return 0.3
	elif active_effects.has(ItemType.PLAYER_SPEED_20):
		return 0.2
	
	return 0.0

func get_fish_slow_effect() -> float:
	"""Get current fish slow effect (0.0 = no effect, 0.7 = 70% slower)"""
	if active_effects.has(ItemType.FISH_SLOW_70):
		return 0.7
	elif active_effects.has(ItemType.FISH_SLOW_50):
		return 0.5
	elif active_effects.has(ItemType.FISH_SLOW_30):
		return 0.3
	
	return 0.0

func get_fish_speed_multiplier() -> float:
	"""Get current fish speed multiplier (slower = lower value)"""
	var multiplier = 1.0
	
	if active_effects.has(ItemType.FISH_SLOW_70):
		multiplier = 0.3  # 70% slower
	elif active_effects.has(ItemType.FISH_SLOW_50):
		multiplier = 0.5  # 50% slower
	elif active_effects.has(ItemType.FISH_SLOW_30):
		multiplier = 0.7  # 30% slower
	
	return multiplier

func get_player_speed_multiplier() -> float:
	"""Get current player speed multiplier"""
	var multiplier = 1.0
	
	if active_effects.has(ItemType.PLAYER_SPEED_40):
		multiplier += 0.40
	elif active_effects.has(ItemType.PLAYER_SPEED_30):
		multiplier += 0.30
	elif active_effects.has(ItemType.PLAYER_SPEED_20):
		multiplier += 0.20
	
	return multiplier

func get_rod_buff_multiplier() -> float:
	"""Get current rod strength multiplier"""
	var multiplier = 1.0
	
	if active_effects.has(ItemType.ROD_BUFF_70):
		multiplier += 0.70
	elif active_effects.has(ItemType.ROD_BUFF_50):
		multiplier += 0.50
	elif active_effects.has(ItemType.ROD_BUFF_30):
		multiplier += 0.30
	
	return multiplier

# Save/Load integration with backward compatibility
func save_data() -> Dictionary:
	"""Save inventory state"""
	# Convert enum keys to strings for JSON compatibility
	var string_inventory = {}
	for item_type in inventory:
		string_inventory[str(item_type)] = inventory[item_type]
	
	var string_effects = {}
	for item_type in active_effects:
		string_effects[str(item_type)] = active_effects[item_type]
	
	return {
		"inventory": string_inventory,
		"active_effects": string_effects
	}

func load_data(data: Dictionary):
	"""Load inventory state with backward compatibility for old boolean system"""
	if data.has("inventory"):
		# Convert string keys back to enum keys
		inventory.clear()
		for string_key in data["inventory"]:
			var enum_key = int(string_key)
			inventory[enum_key] = data["inventory"][string_key]
	
	if data.has("active_effects"):
		# Convert string keys back to enum keys
		active_effects.clear()
		for string_key in data["active_effects"]:
			var enum_key = int(string_key)
			active_effects[enum_key] = data["active_effects"][string_key]
	else:
		# Initialize empty active_effects if not present (backward compatibility)
		active_effects = {}

# Backward compatibility: Convert old boolean flags to new inventory system
func migrate_from_boolean_flags():
	"""Convert old save file boolean flags to new inventory system"""
	# Clear existing inventory
	_initialize_inventory()
	
	# Map old boolean variables to new items
	var boolean_mappings = {
		"has_great_fortune_food": ItemType.GREAT_FORTUNE,
		"has_super_fortune_food": ItemType.SUPER_FORTUNE, 
		"has_ultra_fortune_food": ItemType.ULTRA_FORTUNE,
		"has_recovery_energy_food": ItemType.RECOVERY_ENERGY,
		"has_mighty_energy_food": ItemType.MIGHTY_ENERGY,
		"has_grand_energy_food": ItemType.GRAND_ENERGY,
		"has_fish_slow_potion_30": ItemType.FISH_SLOW_30,
		"has_fish_slow_potion_50": ItemType.FISH_SLOW_50,
		"has_fish_slow_potion_70": ItemType.FISH_SLOW_70,
		"has_player_speed_potion_20": ItemType.PLAYER_SPEED_20,
		"has_player_speed_potion_30": ItemType.PLAYER_SPEED_30,
		"has_player_speed_potion_40": ItemType.PLAYER_SPEED_40,
		"has_rod_buff_potion_30": ItemType.ROD_BUFF_30,
		"has_rod_buff_potion_50": ItemType.ROD_BUFF_50,
		"has_rod_buff_potion_70": ItemType.ROD_BUFF_70
	}
	
	# Convert boolean flags to inventory counts
	for flag_name in boolean_mappings:
		var item_type = boolean_mappings[flag_name]
		if GlobalVariable.get(flag_name) == true:
			# Give player 1 item for each true boolean flag
			inventory[item_type] = 1
	
	# Clear old boolean flags (optional - for clean save files)
	_clear_old_boolean_flags()

func _clear_old_boolean_flags():
	"""Clear old boolean flags from GlobalVariable"""
	var flags_to_clear = [
		"has_great_fortune_food", "has_super_fortune_food", "has_ultra_fortune_food",
		"has_recovery_energy_food", "has_mighty_energy_food", "has_grand_energy_food",
		"has_fish_slow_potion_30", "has_fish_slow_potion_50", "has_fish_slow_potion_70",
		"has_player_speed_potion_20", "has_player_speed_potion_30", "has_player_speed_potion_40",
		"has_rod_buff_potion_30", "has_rod_buff_potion_50", "has_rod_buff_potion_70",
		"has_slow_potion", "has_speed_potion"  # Legacy flags
	]
	
	for flag in flags_to_clear:
		if GlobalVariable.has_method("set"):
			GlobalVariable.set(flag, false)

# Factory Method Pattern: Create items by shop ID
static func get_item_type_from_shop_id(shop_id: String) -> ItemType:
	"""Convert shop item ID to ItemType enum"""
	var shop_mapping = {
		"great_fortune_food": ItemType.GREAT_FORTUNE,
		"super_fortune_food": ItemType.SUPER_FORTUNE,
		"ultra_fortune_food": ItemType.ULTRA_FORTUNE,
		"recovery_energy_food": ItemType.RECOVERY_ENERGY,
		"mighty_energy_food": ItemType.MIGHTY_ENERGY,
		"grand_energy_food": ItemType.GRAND_ENERGY,
		"fish_slow_potion_30": ItemType.FISH_SLOW_30,
		"fish_slow_potion_50": ItemType.FISH_SLOW_50,
		"fish_slow_potion_70": ItemType.FISH_SLOW_70,
		"player_speed_potion_20": ItemType.PLAYER_SPEED_20,
		"player_speed_potion_30": ItemType.PLAYER_SPEED_30,
		"player_speed_potion_40": ItemType.PLAYER_SPEED_40,
		"rod_buff_potion_30": ItemType.ROD_BUFF_30,
		"rod_buff_potion_50": ItemType.ROD_BUFF_50,
		"rod_buff_potion_70": ItemType.ROD_BUFF_70
	}
	
	if not shop_mapping.has(shop_id):
		return ItemType.GREAT_FORTUNE
	
	return shop_mapping[shop_id]
