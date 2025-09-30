extends Node3D
class_name InventoryContainer

@export var inventory : Inventory

func _ready() -> void:
	_check_development()
	
func _check_development():
	inventory.validate_editor_data_integrity()
