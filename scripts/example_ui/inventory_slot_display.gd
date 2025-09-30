extends PanelContainer
class_name InventorySlotDisplay

signal slot_clicked(slot_ui: InventorySlotDisplay)

@onready var panel = $MarginContainer/Panel
@onready var item_name_label = $MarginContainer/Panel/VBoxContainer/ItemNameLabel
@onready var quantity_label = $MarginContainer/Panel/VBoxContainer/QuantityLabel

var item_stack: ItemStack

func set_stack(stack: ItemStack) -> void:
	if is_instance_valid(item_stack) and item_stack.stack_changed.is_connected(_update_visuals):
		item_stack.stack_changed.disconnect(_update_visuals)
		
	item_stack = stack
	# Conecta ao sinal do stack para que a UI se atualize automaticamente
	if not item_stack.stack_changed.is_connected(_update_visuals):
		item_stack.stack_changed.connect(_update_visuals)
		
	_update_visuals()

func _update_visuals() -> void:
	if item_stack == null or item_stack.item == null or item_stack.quantity <= 0:
		item_name_label.text = ""
		quantity_label.text = ""
		self.tooltip_text = ""
	else:
		item_name_label.text = item_stack.item.name
		quantity_label.text = str(item_stack.quantity)
		self.tooltip_text = item_stack.item.name

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if item_stack.item != null :
			print("Slot with " + item_stack.item.name +" Clicked -- " )
		else:
			print("Slot Empty Clicked")
		emit_signal("slot_clicked", self)
	
