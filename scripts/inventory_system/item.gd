@icon("res://addons/p0nni_inventory_system/scripts/script_icons/item.svg")
extends Resource
class_name Item

@export var name : String
@export var description: String
@export var image : Texture2D
@export var max_per_stack: int = 1
@export var layer : String

func _init() -> void:
	layer = "Misc"

func is_equal(other_item: Item) -> bool:
	return self.resource_path == other_item.resource_path
	
func get_layer_name() ->String:
	return layer
