extends Control
class_name InventoriesView

@onready var primary_panel = $HBoxContainer/PrimaryPanel
@onready var secondary_panel = $HBoxContainer/SecondaryPanel

var held_stack_ui: InventorySlotDisplay = null

func _ready() -> void:
	# Conecta aos sinais do autoload
	Inventories.primary_inventory_changed.connect(_on_primary_inventory_changed)
	Inventories.secondary_inventory_changed.connect(_on_secondary_inventory_changed)

	# Conecta aos cliques nos slots de cada painel
	primary_panel.slot_was_clicked.connect(_on_any_slot_clicked)
	secondary_panel.slot_was_clicked.connect(_on_any_slot_clicked)
	
	# Inicializa o estado da UI
	secondary_panel.hide()
	
func _on_primary_inventory_changed(inventory: Inventory) -> void:
	primary_panel.generate_panel(inventory)

func _on_secondary_inventory_changed(inventory: Inventory) -> void:
	if inventory == null:
		secondary_panel.clear_panel()
		secondary_panel.hide()
	else:
		secondary_panel.generate_panel(inventory)
		secondary_panel.show()

func change_panel_color(slot_ui:InventorySlotDisplay,new_color: Color):
	var stylebox_override = slot_ui.panel.get_theme_stylebox("panel").duplicate()
	
	if stylebox_override is StyleBoxFlat:
		stylebox_override.bg_color = new_color
		
	slot_ui.panel.add_theme_stylebox_override("panel",stylebox_override)
		
# Lógica central para mover/trocar itens
func _on_any_slot_clicked(slot_ui: InventorySlotDisplay) -> void:
	
	if held_stack_ui == null:
		# Pega um item se o slot não estiver vazio
		if slot_ui.item_stack.item != null:
			held_stack_ui = slot_ui
			change_panel_color(held_stack_ui,Color.CRIMSON)
	else:
		# Se clicou no mesmo slot, solta ele
		if held_stack_ui == slot_ui:
			change_panel_color(held_stack_ui,Color.BLACK)
			held_stack_ui = null
			return

		# Troca os itens usando a função do controller
		Inventories.change_item_on_stack_for_other(held_stack_ui.item_stack, slot_ui.item_stack)
		
		# Limpa o estado
		change_panel_color(held_stack_ui,Color.BLACK)
		held_stack_ui = null
	
	slot_ui._update_visuals()
