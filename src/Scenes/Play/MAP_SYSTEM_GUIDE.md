# Map System Integration Guide

## Overview
The Map system provides dynamic background management for the fishing game with randomized map changes based on predefined probabilities.

## Files Created
- `Scenes/Play/Map.gd` - Main map controller script
- Integration in `Scenes/Play/Play.gd` - Added map controller setup and event handling

## Map Configuration

### Available Maps (Real Files)
The system uses these map files from `Scenes/Play/img/`:
1. `background.png` - Original Waters (35% probability) - **EXISTING FILE**
2. `coral reef.png` - Vibrant coral formations (30% probability) - **REAL FILE**
3. `deep_sea.png` - Mysterious abyssal depths (20% probability) - **REAL FILE**
4. `swamp.png` - Murky swamp waters (15% probability) - **REAL FILE**

### Map Features
- **Automatic Changes**: Maps change every 45 seconds by default
- **Weighted Probabilities**: Each map has different appearance chances
- **Smooth Transitions**: Fade in/out effects between map changes
- **Event Triggers**: Special fish catches can trigger map changes
- **Level Adaptation**: Map probabilities adjust based on player level

## How to Use in Godot Editor

### 1. Scene Setup (Play.tscn)
The Map controller is automatically instantiated in code, but you can also set it up manually:

```
Play (Node2D)
├── MapController (Map) [added automatically by code]
├── HUD (Control)
├── UILayer (CanvasLayer)
│   ├── QuestUI
│   └── LevelCompletionScreen
└── [Other game nodes]
```

### 2. Script Integration
The Map controller is automatically integrated into `Play.gd`:
- Initialized in `_ready()`
- Connected to fish catching events
- Manages automatic map changes
- Provides manual control functions

### 3. Map Events
The system responds to:
- **Timer Events**: Regular automatic changes
- **Rare Fish**: Epic/Legendary catches trigger 15% chance of map change
- **Level Changes**: Adjusts probabilities based on player progression
- **Manual Triggers**: Can be forced externally

## API Reference

### Map Controller Methods
```gdscript
# Load specific map
map_controller.load_map("ocean_surface", use_transition=true)

# Force random map change
map_controller.force_map_change()

# Get current map info
var info = map_controller.get_current_map_info()

# Adjust settings
map_controller.set_map_change_interval(60.0)
map_controller.enable_automatic_changes(false)
map_controller.set_map_probability("deep_ocean", 0.5)
```

### Play Scene Integration
```gdscript
# Force map change from Play scene
force_map_change()

# Get current map information
var map_info = get_current_map_info()

# Control automatic changes
set_map_change_enabled(false)
```

## Configuration Options

### Map Probabilities by Player Level
- **Beginner (Level 1-4)**: Background 50%, Coral 25%, Deep Sea 15%, Swamp 10%
- **Intermediate (Level 5-9)**: Background 35%, Coral 35%, Deep Sea 20%, Swamp 10%  
- **Advanced (Level 10+)**: Background 25%, Coral 35%, Deep Sea 25%, Swamp 15%

### Timing Settings
- **Default Interval**: 45 seconds between potential changes
- **Change Probability**: 30% chance when timer triggers
- **Transition Duration**: 1.5 seconds fade effect
- **Rare Fish Trigger**: 15% chance on Epic/Legendary catches

## Map Image Requirements

Maps should be:
- **Resolution**: 1152x648 pixels (game standard)
- **Format**: PNG with transparency support
- **Style**: Underwater/ocean themed backgrounds
- **Performance**: Optimized for real-time rendering

## Placeholder System

If map images don't exist, the system creates colored placeholders:
- **Original Waters**: Medium blue (#4D99E6)
- **Coral Reef**: Turquoise (#33CCCC)
- **Deep Sea**: Dark blue (#1A1A80)
- **Murky Swamp**: Murky green (#4D8033)

**Note**: All map files now exist as real artwork, so placeholders are only used as fallbacks for corrupted/missing files.

## Future Enhancements

Potential additions:
- Weather-based map selection
- Time-of-day variations
- Seasonal map rotations
- Custom map probability profiles
- Player preference settings
- Achievement-based map unlocks

## Debug Information

The system provides console output for:
- Map changes and transitions
- Probability calculations
- File loading status
- Timer events
- Player-triggered changes

### Troubleshooting Map Changes

If maps are not changing automatically:

1. **Check Console Output**: Look for these messages:
   - "Map controller initialized"
   - "Map change timer started with interval: Xs"
   - "Map timer timeout triggered! Checking for map change..."

2. **Test Manual Change**: Press M key to force a map change

3. **Check Timer Setup**: 
   - Timer interval reduced to 10 seconds for testing
   - 30% chance to change when timer triggers
   - Maps won't change during transitions

4. **Common Issues**:
   - Timer not starting properly (fixed: now calls `start()` explicitly)
   - Transition state blocking changes
   - Random chance not triggering (only 30% chance)

### Debug Controls
- **M Key**: Force immediate map change
- **Console**: Monitor timer and change events

## Integration with Existing Systems

The map system integrates with:
- **Fish Catching**: Rare catches trigger changes
- **Quest System**: Maps could affect available quests
- **Player Stats**: Level affects map probabilities
- **Potion System**: Could add map-specific potions
- **UI System**: Respects existing UI state management
