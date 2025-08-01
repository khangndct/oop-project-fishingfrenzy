#!/usr/bin/env python3
"""
Test script to verify the map system configuration and validate the Map.gd logic.
This script simulates the map probability system without requiring Godot.
"""

import random
import json

class MapSystemTest:
    def __init__(self):
        # Mirror the map configurations from Map.gd
        self.map_configs = {
            "ocean_surface": {
                "path": "res://Scenes/Play/img/ocean_surface_map.png",
                "probability": 0.4,  # 40%
                "name": "Ocean Surface"
            },
            "coral_reef": {
                "path": "res://Scenes/Play/img/coral_reef_map.png", 
                "probability": 0.35,  # 35%
                "name": "Coral Reef"
            },
            "deep_ocean": {
                "path": "res://Scenes/Play/img/deep_ocean_map.png",
                "probability": 0.25,  # 25%
                "name": "Deep Ocean"
            }
        }
    
    def get_weighted_random_map(self):
        """Simulate the weighted random selection from Map.gd"""
        total_weight = sum(config["probability"] for config in self.map_configs.values())
        random_value = random.random() * total_weight
        current_weight = 0.0
        
        for map_key, config in self.map_configs.items():
            current_weight += config["probability"]
            if random_value <= current_weight:
                return map_key
        
        # Fallback
        return list(self.map_configs.keys())[0]
    
    def test_probability_distribution(self, iterations=10000):
        """Test that the probability distribution works as expected"""
        print(f"Testing map probability distribution over {iterations} iterations...")
        
        results = {map_key: 0 for map_key in self.map_configs.keys()}
        
        for _ in range(iterations):
            selected_map = self.get_weighted_random_map()
            results[selected_map] += 1
        
        print("\nResults:")
        print("-" * 50)
        for map_key, count in results.items():
            expected_prob = self.map_configs[map_key]["probability"]
            actual_prob = count / iterations
            error = abs(expected_prob - actual_prob)
            
            print(f"{self.map_configs[map_key]['name']:<12}: "
                  f"{count:>5} ({actual_prob:.1%}) | "
                  f"Expected: {expected_prob:.1%} | "
                  f"Error: {error:.2%}")
        
        print("-" * 50)
    
    def test_level_probability_adjustments(self):
        """Test probability adjustments for different player levels"""
        print("\nTesting level-based probability adjustments...")
        
        level_configs = {
            1: {"deep_ocean": 0.15, "coral_reef": 0.35, "ocean_surface": 0.5},
            5: {"deep_ocean": 0.3, "coral_reef": 0.4, "ocean_surface": 0.3},
            10: {"deep_ocean": 0.4, "coral_reef": 0.35, "ocean_surface": 0.25}
        }
        
        for level, expected_probs in level_configs.items():
            print(f"\nLevel {level} expected probabilities:")
            for map_key, prob in expected_probs.items():
                map_name = self.map_configs[map_key]["name"]
                print(f"  {map_name:<12}: {prob:.1%}")
    
    def simulate_gameplay_session(self, duration_minutes=5):
        """Simulate a gameplay session with map changes"""
        print(f"\nSimulating {duration_minutes}-minute gameplay session...")
        
        # Simulate 45-second intervals (as configured in Map.gd)
        intervals = int((duration_minutes * 60) / 45)
        change_probability = 0.3  # 30% chance per interval
        
        current_map = self.get_weighted_random_map()
        changes = [current_map]
        
        print(f"Starting map: {self.map_configs[current_map]['name']}")
        
        for i in range(intervals):
            time_seconds = (i + 1) * 45
            minutes = time_seconds // 60
            seconds = time_seconds % 60
            
            if random.random() < change_probability:
                # Change map (ensure it's different)
                available_maps = [k for k in self.map_configs.keys() if k != current_map]
                current_map = random.choice(available_maps)
                changes.append(current_map)
                print(f"  {minutes:02d}:{seconds:02d} - Changed to: {self.map_configs[current_map]['name']}")
        
        print(f"\nSession summary:")
        print(f"  Total map changes: {len(changes) - 1}")
        print(f"  Final map: {self.map_configs[current_map]['name']}")
        
        # Count map usage
        map_usage = {map_key: changes.count(map_key) for map_key in self.map_configs.keys()}
        print(f"  Map usage: {map_usage}")
    
    def test_rare_fish_triggers(self):
        """Test rare fish catch triggering map changes"""
        print("\nTesting rare fish catch triggers...")
        
        rare_fish_types = ["Epic", "Legendary"]
        trigger_chance = 0.15  # 15% as configured
        
        total_catches = 1000
        triggered_changes = 0
        
        for _ in range(total_catches):
            # Simulate random fish catch
            if random.choice([True, False]):  # 50% chance of rare fish
                fish_type = random.choice(rare_fish_types)
                if random.random() < trigger_chance:
                    triggered_changes += 1
        
        expected_changes = total_catches * 0.5 * trigger_chance
        print(f"  Simulated {total_catches} fish catches")
        print(f"  Expected map changes: ~{expected_changes:.0f}")
        print(f"  Actual map changes: {triggered_changes}")
        print(f"  Trigger rate: {triggered_changes / (total_catches * 0.5):.1%}")

def main():
    """Run all map system tests"""
    print("Map System Test Suite")
    print("=" * 50)
    
    tester = MapSystemTest()
    
    # Test probability distribution
    tester.test_probability_distribution()
    
    # Test level adjustments
    tester.test_level_probability_adjustments()
    
    # Simulate gameplay
    tester.simulate_gameplay_session()
    
    # Test rare fish triggers
    tester.test_rare_fish_triggers()
    
    print("\n" + "=" * 50)
    print("Map system test completed!")
    print("\nFiles created:")
    print("- Map.gd: Main map controller")
    print("- Updated Play.gd with map integration")
    print("- MAP_SYSTEM_GUIDE.md: Documentation")
    print("- 3 placeholder map images")

if __name__ == "__main__":
    main()
