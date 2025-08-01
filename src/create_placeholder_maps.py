#!/usr/bin/env python3
"""
Create placeholder map images for the Fishing Frenzy game map system.
These are simple colored backgrounds that serve as placeholders until actual map art is created.
"""

from PIL import Image
import os

def create_placeholder_maps():
    """Create placeholder map images"""
    
    # Ensure directory exists
    img_dir = "Scenes/Play/img"
    os.makedirs(img_dir, exist_ok=True)
    
    # Map configurations
    maps = {
        "ocean_surface_map.png": {
            "color": (107, 179, 255),  # Light blue
            "description": "Ocean surface with clear blue water"
        },
        "coral_reef_map.png": {
            "color": (51, 204, 204),   # Turquoise
            "description": "Coral reef with vibrant turquoise water"
        },
        "deep_ocean_map.png": {
            "color": (26, 26, 128),    # Dark blue
            "description": "Deep ocean with dark mysterious water"
        }
    }
    
    # Standard game resolution
    width, height = 1152, 648
    
    print("Creating placeholder map images...")
    
    for filename, config in maps.items():
        # Create solid color image
        image = Image.new('RGB', (width, height), config["color"])
        
        # Add simple gradient effect
        pixels = image.load()
        for y in range(height):
            # Darken towards bottom for depth effect
            factor = 1.0 - (y / height) * 0.3
            for x in range(width):
                r, g, b = config["color"]
                pixels[x, y] = (
                    int(r * factor),
                    int(g * factor), 
                    int(b * factor)
                )
        
        # Save image
        filepath = os.path.join(img_dir, filename)
        image.save(filepath)
        print(f"Created: {filepath} - {config['description']}")
    
    print("\nPlaceholder maps created successfully!")
    print("These simple colored backgrounds will work until actual map artwork is ready.")

if __name__ == "__main__":
    create_placeholder_maps()
