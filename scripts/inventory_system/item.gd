@icon("res://addons/p0nni_inventory_system/scripts/script_icons/item.svg")
extends Resource
class_name Item

enum ItemLayer {
	Armor,
	Consumible,
	Misc
}

var layer: ItemLayer = ItemLayer.Misc
@export var name : String
@export var max_per_stack: int = 1

func is_equal(other_item: Item):
	return self.resource_path == other_item.resource_path
