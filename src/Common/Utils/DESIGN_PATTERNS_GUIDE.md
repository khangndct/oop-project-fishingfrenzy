# Design Patterns for FishData and Fish System

## Current Issues with the Existing FishFactory

The current `FishFactory` class is **NOT** implementing a proper Factory Pattern. It's more of a basic spawner that:

1. **Random Selection Only**: Uses `pick_random()` without considering rarity weights
2. **No Abstraction**: All fish are identical except for data
3. **Tight Coupling**: Hard-coded to one fish scene
4. **Limited Extensibility**: Can't easily add new fish types or behaviors

## Recommended Design Patterns

### 1. Factory Method Pattern ✅
**Purpose**: Create different types of fish based on rarity
**Benefits**: 
- Each rarity can have its own creation logic
- Easy to add new fish types
- Separates object creation from business logic

```gdscript
# Base factory with template method
class BaseFishFactory:
    func create_fish(data: FishData) -> Fish:
        var fish = _instantiate_fish()
        _configure_fish(fish, data)
        _apply_fish_behavior(fish, data)
        return fish

# Concrete factories for each rarity
class CommonFishFactory extends BaseFishFactory
class RareFishFactory extends BaseFishFactory  
class LegendaryFishFactory extends BaseFishFactory
```

### 2. Strategy Pattern ✅
**Purpose**: Different behavior strategies for each fish rarity
**Benefits**:
- Runtime behavior switching
- Easy to add new behaviors
- Cleaner than large switch statements

```gdscript
# In FishData class
class FishBehaviorStrategy:
    func get_speed_multiplier() -> float
    func get_movement_pattern() -> String
    func get_special_ability() -> String

class LegendaryBehavior extends FishBehaviorStrategy:
    func get_speed_multiplier() -> float: return 2.0
    func get_movement_pattern() -> String: return "teleport"
```

### 3. Builder Pattern ✅
**Purpose**: Construct complex fish objects step by step
**Benefits**:
- Flexible fish creation
- Reusable construction process
- Clear separation of construction logic

```gdscript
class FishBuilder:
    func set_scene(scene: PackedScene) -> FishBuilder
    func set_data(data: FishData) -> FishBuilder
    func set_position(pos: Vector2) -> FishBuilder
    func apply_rarity_effects() -> FishBuilder
    func build() -> Fish
```

### 4. Observer Pattern ✅
**Purpose**: Notify multiple systems about fish events
**Benefits**:
- Loose coupling between systems
- Easy to add new observers (sound, particles, stats)
- Event-driven architecture

```gdscript
class FishEventManager:
    func notify_fish_spawned(fish: Fish)
    func notify_fish_caught(fish: Fish)
    func add_observer(observer: FishEventObserver)
```

### 5. Abstract Factory Pattern ✅
**Purpose**: Create families of related fish objects
**Benefits**:
- Creates consistent object families
- Easy to switch between different fish ecosystems
- Ensures related objects work together

## For the FishData Class Specifically

### Current FishData Design Issues:
1. **Hard-coded stats dictionary** - not extensible
2. **No behavior differentiation** - all fish act the same
3. **Limited rarity effects** - only affects basic stats

### Recommended Improvements:

#### 1. Strategy Pattern for Behavior
```gdscript
class_name ImprovedFishData extends Resource

var behavior_strategy: FishBehaviorStrategy

func get_effective_speed() -> float:
    return get_stat("speed") * behavior_strategy.get_speed_multiplier()

func get_movement_pattern() -> String:
    return behavior_strategy.get_movement_pattern()
```

#### 2. Template Method Pattern
```gdscript
func initialize_fish(fish: Fish) -> void:
    _set_basic_properties(fish)
    _apply_rarity_effects(fish)
    _setup_special_abilities(fish)

# Subclasses can override specific steps
func _apply_rarity_effects(fish: Fish) -> void:
    # Default implementation
```

#### 3. State Pattern (for Fish behavior)
```gdscript
# In Fish class
enum FishState { SWIMMING, FLEEING, CAUGHT, SPECIAL_ABILITY }

class FishStateMachine:
    func transition_to(new_state: FishState)
    func update(delta: float)
```

## Implementation Priority

1. **Start with Factory Method Pattern** - Fix the basic factory issues
2. **Add Strategy Pattern** - Give different rarities unique behaviors  
3. **Implement Observer Pattern** - Decouple event handling
4. **Consider Builder Pattern** - If fish creation becomes complex
5. **Add State Pattern** - For advanced fish AI behaviors

## Benefits of These Patterns

- **Maintainability**: Each pattern has a single responsibility
- **Extensibility**: Easy to add new fish types, behaviors, and observers
- **Testability**: Each component can be tested independently
- **Performance**: More efficient than large conditional statements
- **Code Reuse**: Patterns promote reusable components

The current `FishFactory` would benefit most from implementing the **Factory Method Pattern** first, as it directly addresses the main architectural issues.
