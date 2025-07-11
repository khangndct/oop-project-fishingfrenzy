class_name FishData

extends Resource

enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY}

@export var fish_name : String
@export var rarity : Rarity
@export var sprite_texture : Texture2D

var rarity_stats := {
	Rarity.COMMON: {
		"speed" = 3,
		"strength" = 5,
		"value" = 1,
	},
	Rarity.UNCOMMON: {
		"speed" = 5,
		"strength" = 10,
		"value" = 3,
	},
	Rarity.RARE: {
		"speed" = 7,
		"strength" = 15,
		"value" = 5,
	},
		Rarity.EPIC: {
		"speed" = 9,
		"strength" = 20,
		"value" = 10,
	},
		Rarity.LEGENDARY: {
		"speed" = 12,
		"strength" = 25,
		"value" = 20,
	},
}

func get_stat(stat : String) -> Variant:
	return rarity_stats.get(rarity, {}).get(stat, null)
