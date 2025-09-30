@icon("res://addons/p0nni_inventory_system/scripts/script_icons/item_stack.svg")
extends Resource
class_name ItemStack

signal stack_changed

@export var item : Item = null
@export var quantity: int = 0


func swap_item(new_item: Item, qty_to_push: int):
	item = new_item
	quantity = qty_to_push
	stack_changed.emit()

## Adiciona um item a esta pilha e retorna a quantidade que sobrou.
func push_item(new_item: Item, qty_to_push: int) -> int:
	if new_item == null or qty_to_push <= 0:
		return qty_to_push
	var current_max_size = 0
	if item != null:
		if not item.is_equal(new_item):
			return qty_to_push
		current_max_size = item.max_per_stack
	else:
		current_max_size = new_item.max_per_stack

	var free_space = current_max_size - quantity
	
	if free_space <= 0:
		return qty_to_push

	var actual_added = min(qty_to_push, free_space)
	
	if item == null:
		item = new_item
	
	quantity += actual_added
	stack_changed.emit()
	return qty_to_push - actual_added
	
func reset(force:bool = false) -> void:
	if(force):
		item = null
		quantity = 0
	if item != null && quantity == 0:
		item = null
		
	stack_changed.emit()

func reset_quantity():
	quantity = 0
	stack_changed.emit()

func use_item():
	quantity -= 1
	reset()
	
