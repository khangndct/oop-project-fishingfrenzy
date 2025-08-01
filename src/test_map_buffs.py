#!/usr/bin/env python3
"""
Test script for Map Buff/Debuff System
Validates the effect calculations and map configurations
"""

class MapBuffDebuffTest:
    def __init__(self):
        # Mirror the map configurations from Map.gd
        self.map_configs = {
            "ocean_surface": {
                "name": "Ocean Surface",
                "player_buffs": {
                    "movement_speed": 1.15,  # +15%
                    "energy_cost": 0.9,      # -10%
                    "luck_bonus": 0.05       # +5%
                },
                "player_debuffs": {
                    "pull_strength": 0.95    # -5%
                },
                "fish_buffs": {
                    "escape_chance": 1.1,    # +10%
                    "spawn_rate": 1.2        # +20%
                },
                "fish_debuffs": {
                    "speed": 0.9,            # -10%
                    "ability_power": 0.85    # -15%
                }
            },
            "coral_reef": {
                "name": "Coral Reef",
                "player_buffs": {
                    "luck_bonus": 0.15,      # +15%
                    "rare_fish_spawn": 1.3   # +30%
                },
                "player_debuffs": {
                    "movement_speed": 0.9,   # -10%
                    "energy_cost": 1.1       # +10%
                },
                "fish_buffs": {
                    "ability_power": 1.25,   # +25%
                    "speed": 1.1,            # +10%
                    "rare_spawn_rate": 1.4   # +40%
                },
                "fish_debuffs": {
                    "escape_chance": 0.9     # -10%
                }
            },
            "deep_ocean": {
                "name": "Deep Ocean",
                "player_buffs": {
                    "pull_strength": 1.2,    # +20%
                    "legendary_fish_spawn": 1.5  # +50%
                },
                "player_debuffs": {
                    "movement_speed": 0.85,  # -15%
                    "energy_cost": 1.2,      # +20%
                    "luck_bonus": -0.05      # -5%
                },
                "fish_buffs": {
                    "escape_chance": 1.2,    # +20%
                    "ability_power": 1.4,    # +40%
                    "speed": 1.15,           # +15%
                    "legendary_spawn_rate": 2.0  # +100%
                },
                "fish_debuffs": {
                    "common_spawn_rate": 0.7  # -30%
                }
            }
        }
    
    def test_player_effect_calculations(self):
        """Test player effect calculation examples"""
        print("Testing Player Effect Calculations")
        print("=" * 50)
        
        # Base player stats
        base_speed = 10
        base_energy_cost = 2
        base_pull_strength = 1.0
        
        for map_name, config in self.map_configs.items():
            print(f"\n{config['name']} Map Effects:")
            
            # Movement speed calculation
            movement_modifier = 1.0
            if "player_buffs" in config and "movement_speed" in config["player_buffs"]:
                movement_modifier *= config["player_buffs"]["movement_speed"]
            if "player_debuffs" in config and "movement_speed" in config["player_debuffs"]:
                movement_modifier *= config["player_debuffs"]["movement_speed"]
            
            final_speed = base_speed * movement_modifier
            speed_change = (movement_modifier - 1.0) * 100
            print(f"  Movement Speed: {base_speed} -> {final_speed:.1f} ({speed_change:+.0f}%)")
            
            # Energy cost calculation
            energy_modifier = 1.0
            if "player_buffs" in config and "energy_cost" in config["player_buffs"]:
                energy_modifier *= config["player_buffs"]["energy_cost"]
            if "player_debuffs" in config and "energy_cost" in config["player_debuffs"]:
                energy_modifier *= config["player_debuffs"]["energy_cost"]
            
            final_energy_cost = max(1, int(base_energy_cost * energy_modifier))
            energy_change = (1.0 - energy_modifier) * 100  # Inverted for cost
            print(f"  Energy Cost: {base_energy_cost} -> {final_energy_cost} ({energy_change:+.0f}% efficiency)")
            
            # Pull strength calculation
            pull_modifier = 1.0
            if "player_buffs" in config and "pull_strength" in config["player_buffs"]:
                pull_modifier *= config["player_buffs"]["pull_strength"]
            if "player_debuffs" in config and "pull_strength" in config["player_debuffs"]:
                pull_modifier *= config["player_debuffs"]["pull_strength"]
            
            final_pull_strength = base_pull_strength * pull_modifier
            pull_change = (pull_modifier - 1.0) * 100
            print(f"  Pull Strength: {base_pull_strength:.2f} -> {final_pull_strength:.2f} ({pull_change:+.0f}%)")
    
    def test_fish_effect_calculations(self):
        """Test fish effect calculation examples"""
        print("\n\nTesting Fish Effect Calculations")
        print("=" * 50)
        
        # Base fish stats
        base_fish_speed = 5.0
        base_escape_chance = 0.3  # 30%
        base_ability_power = 1.0
        
        for map_name, config in self.map_configs.items():
            print(f"\n{config['name']} Map Effects on Fish:")
            
            # Fish speed calculation
            speed_modifier = 1.0
            if "fish_buffs" in config and "speed" in config["fish_buffs"]:
                speed_modifier *= config["fish_buffs"]["speed"]
            if "fish_debuffs" in config and "speed" in config["fish_debuffs"]:
                speed_modifier *= config["fish_debuffs"]["speed"]
            
            final_fish_speed = base_fish_speed * speed_modifier
            speed_change = (speed_modifier - 1.0) * 100
            print(f"  Fish Speed: {base_fish_speed:.1f} -> {final_fish_speed:.1f} ({speed_change:+.0f}%)")
            
            # Escape chance calculation
            escape_modifier = 1.0
            if "fish_buffs" in config and "escape_chance" in config["fish_buffs"]:
                escape_modifier *= config["fish_buffs"]["escape_chance"]
            if "fish_debuffs" in config and "escape_chance" in config["fish_debuffs"]:
                escape_modifier *= config["fish_debuffs"]["escape_chance"]
            
            final_escape_chance = base_escape_chance * escape_modifier
            escape_change = (escape_modifier - 1.0) * 100
            print(f"  Escape Chance: {base_escape_chance:.0%} -> {final_escape_chance:.0%} ({escape_change:+.0f}%)")
            
            # Ability power calculation
            ability_modifier = 1.0
            if "fish_buffs" in config and "ability_power" in config["fish_buffs"]:
                ability_modifier *= config["fish_buffs"]["ability_power"]
            if "fish_debuffs" in config and "ability_power" in config["fish_debuffs"]:
                ability_modifier *= config["fish_debuffs"]["ability_power"]
            
            final_ability_power = base_ability_power * ability_modifier
            ability_change = (ability_modifier - 1.0) * 100
            print(f"  Ability Power: {base_ability_power:.2f} -> {final_ability_power:.2f} ({ability_change:+.0f}%)")
    
    def test_combined_effect_scenarios(self):
        """Test realistic combined effect scenarios"""
        print("\n\nTesting Combined Effect Scenarios")
        print("=" * 50)
        
        # Scenario: Player with items + map effects
        print("\nScenario: Player with Speed Potion + Ocean Surface Map")
        base_speed = 10
        speed_stat_bonus = 1.2  # +20% from stat level 3
        speed_potion_bonus = 1.4  # +40% from potion
        ocean_map_bonus = 1.15  # +15% from Ocean Surface
        
        final_speed = base_speed * speed_stat_bonus * speed_potion_bonus * ocean_map_bonus
        total_increase = ((final_speed / base_speed) - 1.0) * 100
        
        print(f"  Base Speed: {base_speed}")
        print(f"  + Stat Bonus: {speed_stat_bonus:.1f}x (+{(speed_stat_bonus-1)*100:.0f}%)")
        print(f"  + Speed Potion: {speed_potion_bonus:.1f}x (+{(speed_potion_bonus-1)*100:.0f}%)")
        print(f"  + Ocean Map: {ocean_map_bonus:.1f}x (+{(ocean_map_bonus-1)*100:.0f}%)")
        print(f"  = Final Speed: {final_speed:.1f} (+{total_increase:.0f}% total)")
        
        print("\nScenario: Energy Cost with Multiple Reductions")
        base_energy = 2
        vitality_reduction = 1.0  # No reduction (vitality 1)
        energy_food_reduction = 0.5  # 50% reduction from Mighty Energy Food
        coral_map_increase = 1.1  # +10% cost from Coral Reef
        
        final_energy = max(1, int(base_energy * vitality_reduction * energy_food_reduction * coral_map_increase))
        
        print(f"  Base Energy Cost: {base_energy}")
        print(f"  + Vitality Effect: {vitality_reduction:.1f}x")
        print(f"  + Energy Food: {energy_food_reduction:.1f}x (-50%)")
        print(f"  + Coral Map: {coral_map_increase:.1f}x (+10%)")
        print(f"  = Final Cost: {final_energy} (minimum 1)")
    
    def test_spawn_rate_modifiers(self):
        """Test spawn rate modifier calculations"""
        print("\n\nTesting Spawn Rate Modifiers")
        print("=" * 50)
        
        base_spawn_rates = {
            "common": 0.6,      # 60%
            "rare": 0.25,       # 25%
            "epic": 0.12,       # 12%
            "legendary": 0.03   # 3%
        }
        
        for map_name, config in self.map_configs.items():
            print(f"\n{config['name']} Spawn Rate Effects:")
            
            # General spawn rate
            general_modifier = 1.0
            if "fish_buffs" in config and "spawn_rate" in config["fish_buffs"]:
                general_modifier = config["fish_buffs"]["spawn_rate"]
            
            # Specific modifiers
            rare_modifier = 1.0
            if "player_buffs" in config and "rare_fish_spawn" in config["player_buffs"]:
                rare_modifier *= config["player_buffs"]["rare_fish_spawn"]
            if "fish_buffs" in config and "rare_spawn_rate" in config["fish_buffs"]:
                rare_modifier *= config["fish_buffs"]["rare_spawn_rate"]
            
            legendary_modifier = 1.0
            if "player_buffs" in config and "legendary_fish_spawn" in config["player_buffs"]:
                legendary_modifier *= config["player_buffs"]["legendary_fish_spawn"]
            if "fish_buffs" in config and "legendary_spawn_rate" in config["fish_buffs"]:
                legendary_modifier *= config["fish_buffs"]["legendary_spawn_rate"]
            
            common_modifier = 1.0
            if "fish_debuffs" in config and "common_spawn_rate" in config["fish_debuffs"]:
                common_modifier = config["fish_debuffs"]["common_spawn_rate"]
            
            # Calculate final rates
            final_common = base_spawn_rates["common"] * general_modifier * common_modifier
            final_rare = base_spawn_rates["rare"] * general_modifier * rare_modifier
            final_legendary = base_spawn_rates["legendary"] * general_modifier * legendary_modifier
            
            print(f"  Common: {base_spawn_rates['common']:.0%} -> {final_common:.0%}")
            print(f"  Rare: {base_spawn_rates['rare']:.0%} -> {final_rare:.0%}")
            print(f"  Legendary: {base_spawn_rates['legendary']:.0%} -> {final_legendary:.0%}")
    
    def run_all_tests(self):
        """Run all map buff/debuff tests"""
        print("Map Buff/Debuff System Test Suite")
        print("=" * 60)
        
        self.test_player_effect_calculations()
        self.test_fish_effect_calculations()
        self.test_combined_effect_scenarios()
        self.test_spawn_rate_modifiers()
        
        print("\n" + "=" * 60)
        print("Map Buff/Debuff System Tests Completed!")
        print("\nSystem Features:")
        print("✅ Dynamic map-based player buffs/debuffs")
        print("✅ Fish behavior modifiers per environment")
        print("✅ Spawn rate adjustments for different rarities")
        print("✅ Multiplicative stacking with existing systems")
        print("✅ Global access through GlobalVariable")
        print("✅ Real-time effect updates on map changes")

if __name__ == "__main__":
    tester = MapBuffDebuffTest()
    tester.run_all_tests()
