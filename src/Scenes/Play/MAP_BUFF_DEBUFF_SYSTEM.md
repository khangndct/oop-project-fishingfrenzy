# Map Buff/Debuff System Documentation

## Overview
The map system now provides dynamic buffs and debuffs that affect both players and fish during gameplay. Each map environment has unique characteristics that modify game mechanics, similar to the existing item/potion system.

## Map Configurations

### 🌊 Original Waters
**Probability**: 35% | **Environment**: Classic fishing grounds with balanced conditions

**Player Effects:**
- ✅ **Energy Cost**: -5% (familiar waters)
- Balanced map with minimal effects - ideal for beginners

**Fish Effects:**
- ✅ **Spawn Rate**: +10% (well-populated waters)
- No significant debuffs - steady fish behavior

### 🪸 Coral Reef
**Probability**: 30% | **Environment**: Vibrant coral formations teeming with life

**Player Effects:**
- ✅ **Luck Bonus**: +15% (diverse ecosystem increases luck)
- ✅ **Rare Fish Spawn**: +30% (rich biodiversity)
- ❌ **Movement Speed**: -10% (obstacles slow movement)
- ❌ **Energy Cost**: +10% (more challenging environment)

**Fish Effects:**
- ✅ **Ability Power**: +25% (coral provides cover for abilities)
- ✅ **Speed**: +10% (agile reef fish)
- ✅ **Rare Spawn Rate**: +40% (diverse species)
- ❌ **Escape Chance**: -10% (confined reef space)

### 🌑 Deep Sea
**Probability**: 20% | **Environment**: Mysterious abyssal depths with rare creatures

**Player Effects:**
- ✅ **Pull Strength**: +20% (pressure training effect)
- ✅ **Legendary Fish Spawn**: +50% (rare deep-sea creatures)
- ❌ **Movement Speed**: -15% (pressure resistance required)
- ❌ **Energy Cost**: +20% (deep water strain)
- ❌ **Luck Bonus**: -5% (harder to see in depths)

**Fish Effects:**
- ✅ **Escape Chance**: +20% (vast open space)
- ✅ **Ability Power**: +40% (mysterious deep-sea powers)
- ✅ **Speed**: +15% (powerful deep-water fish)
- ✅ **Legendary Spawn Rate**: +100% (rare species habitat)
- ❌ **Common Spawn Rate**: -30% (fewer surface species)

### 🐸 Murky Swamp
**Probability**: 15% | **Environment**: Mysterious swamp waters with unique species

**Player Effects:**
- ✅ **Energy Cost**: -15% (buoyant swamp water)
- ✅ **Pull Strength**: +10% (dense water resistance training)
- ✅ **Rare Fish Spawn**: +20% (unique swamp species)
- ❌ **Movement Speed**: -20% (thick water/vegetation)
- ❌ **Luck Bonus**: -10% (murky water reduces visibility)

**Fish Effects:**
- ✅ **Ability Power**: +30% (swamp magic)
- ✅ **Escape Chance**: +15% (vegetation cover)
- ✅ **Rare Spawn Rate**: +50% (swamp specialties)
- ❌ **Speed**: -5% (adapted to thick water)
- ❌ **Common Spawn Rate**: -20% (specialized environment)

## Integration Points

### Player System Integration
The map effects are integrated into the Player.gd through the following methods:

```gdscript
# Energy system with map effects
func get_energy_cost() -> int:
    # Combines base cost + food effects + map effects

# Movement with map effects  
func _physics_process(_delta):
    # Applies stat bonuses + potion effects + map effects

# Combat abilities with map effects
func get_pull_strength() -> float:
    # Combines strength stat + map modifiers

func get_luck_bonus() -> float:
    # Combines luck stat + map bonuses
```

### Global Access System
Map effects are accessible globally through `GlobalVariable`:

```gdscript
# Player effect getters
GlobalVariable.get_map_player_movement_speed_modifier()
GlobalVariable.get_map_player_energy_cost_modifier()
GlobalVariable.get_map_player_pull_strength_modifier()
GlobalVariable.get_map_player_luck_bonus()

# Fish effect getters
GlobalVariable.get_map_fish_speed_modifier()
GlobalVariable.get_map_fish_escape_chance_modifier()
GlobalVariable.get_map_fish_ability_power_modifier()

# Spawn rate modifiers
GlobalVariable.get_map_rare_fish_spawn_modifier()
GlobalVariable.get_map_legendary_fish_spawn_modifier()
GlobalVariable.get_map_common_fish_spawn_modifier()
```

## Effect Calculation System

### Multiplicative Stacking
Map effects stack multiplicatively with existing systems:

```gdscript
# Example: Player movement speed calculation
base_speed = 10
stat_bonus = 1.0 + (speed_stat - 1) * 0.1    # +10% per stat point
potion_bonus = 1.0 + potion_effect             # Item system bonus
map_modifier = get_map_movement_speed_modifier() # Map system bonus

final_speed = base_speed * stat_bonus * potion_bonus * map_modifier
```

### Energy Cost Example
```gdscript
# Energy cost with all modifiers
base_cost = 2
food_modifier = 0.5  # 50% reduction from energy food
map_modifier = 0.9   # 10% reduction from Ocean Surface

final_cost = max(1, int(base_cost * food_modifier * map_modifier))
# Result: max(1, int(2 * 0.5 * 0.9)) = max(1, 0) = 1
```

## Fish System Integration

The fish system should integrate these effects for:

### Fish Behavior
- **Speed**: Apply `get_map_fish_speed_modifier()` to fish movement
- **Escape Chance**: Apply `get_map_fish_escape_chance_modifier()` to escape calculations
- **Ability Power**: Apply `get_map_fish_ability_power_modifier()` to special abilities

### Spawn Rates
- **Rare Fish**: Multiply spawn rates by `get_map_rare_fish_spawn_modifier()`
- **Legendary Fish**: Multiply spawn rates by `get_map_legendary_fish_spawn_modifier()`
- **Common Fish**: Multiply spawn rates by `get_map_common_fish_spawn_modifier()`

## Dynamic Map Changes

### Automatic Changes
- Maps change every 45 seconds with 30% probability
- Epic/Legendary fish catches trigger 15% chance of map change
- Map changes include smooth fade transitions

### Effect Updates
When maps change:
1. `_on_map_changed()` is triggered
2. `GlobalVariable.update_current_map_effects()` updates cached effects
3. All systems automatically use new modifiers
4. Console output shows effect changes

## Shop System Integration

Map effects complement the existing item system in the shop:

### Item Categories vs Map Effects
- **Items**: Temporary session-based effects (potions, food)
- **Maps**: Environmental effects that change dynamically
- **Stats**: Permanent character progression

### Combined Effects Example
```
Ocean Surface Map: +15% movement speed
Player Speed Potion 40%: +40% movement speed  
Speed Stat Level 3: +20% movement speed

Total Movement Speed: base * 1.15 * 1.40 * 1.20 = base * 1.932 (93.2% increase)
```

## Console Feedback

The system provides detailed console output for debugging:

```
Map Environment: Coral Reef
Player Effects:
  Energy Efficiency: +10%
  Movement Speed: -10%
Fish Behavior:
  Fish Speed: +10%
  Escape Chance: -10%
```

## Future Enhancements

Potential expansions:
- **Weather Effects**: Storms, calm weather affecting maps
- **Time-based Variations**: Day/night cycles modifying effects
- **Player Level Scaling**: Higher level players get different effect magnitudes
- **Map-specific Items**: Special potions that only work in certain environments
- **Combo Effects**: Bonuses when specific items are used in matching environments

## Implementation Notes

1. **Performance**: Effects are cached and only recalculated on map changes
2. **Backwards Compatibility**: System provides 1.0 defaults when map controller isn't available
3. **Modularity**: Easy to modify effects by updating the `map_configs` dictionary
4. **Extensibility**: New maps can be added with custom effect profiles
