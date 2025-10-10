extends PanelContainer
class_name InventoryPanel
signal slot_was_clicked(slot_ui: InventorySlotDisplay)

@onready var grid_container = $MarginContainer/GridContainer
const SLOT_UI_SCENE = preload("res://addons/p0nni_inventory_system/scenes/UI/inventory_slot_display.tscn")

# Gera os slots da UI com base em um recurso de inventário
func generate_panel(inventory: Inventory) -> void:
	clear_panel() # Limpa slots antigos
	if inventory == null:
		return
		
	for stack in inventory.stacks:
		var slot_ui_instance = SLOT_UI_SCENE.instantiate()
		grid_container.add_child(slot_ui_instance)
		slot_ui_instance.set_stack(stack)   
		slot_ui_instance.slot_clicked.connect(_on_slot_clicked)

# Limpa todos os slots da grade
func clear_panel() -> void:
	for child in grid_container.get_children():
		child.queue_free()

# Propaga o sinal para o controlador de UI principal
func _on_slot_clicked(slot_ui: InventorySlotDisplay):
	emit_signal("slot_was_clicked", slot_ui)
