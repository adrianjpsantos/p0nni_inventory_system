@icon("res://addons/p0nni_inventory_system/scripts/script_icons/inventories_controller.svg")
extends Node
class_name InventoriesController
#DEVE SER COLOCADO COMO AUTO_LOAD PARA PODER MODIFICAR O SECONDARY INVENTORY E A UI PODER USAR

signal primary_inventory_changed(primary:Inventory)
signal secondary_inventory_changed(secondary:Inventory)

var _primary_inventory : Inventory #NORMALMENTE O INVENTARIO DO PLAYER
var _secondary_inventory: Inventory

func get_primary() -> Inventory:
	return _primary_inventory

func get_secondary() -> Inventory:
	return _secondary_inventory

# Deve ser chamado APENAS uma vez na inicialização do jogo ou do Player.
func set_primary_inventory(inventory: Inventory) -> void:
	if _primary_inventory == null:
		_primary_inventory = inventory
		primary_inventory_changed.emit(_primary_inventory)
		if Engine.is_editor_hint():
			print("✅ Inventário Primário definido com sucesso.")
		return
	
	if Engine.is_editor_hint():
		printerr("NAO PODE MUDAR O INVENTARIO PRIMARIO SE JA TIVER ALGUM ATIVO, E NAO PODE REMOVER DEPOIS DE INICIADO")

func set_secondary_inventory(inventory: Inventory) -> void:
	if _secondary_inventory == null:
		_secondary_inventory = inventory
		secondary_inventory_changed.emit(_secondary_inventory)
		if Engine.is_editor_hint():
			print("✅ Inventário Secundario definido com sucesso.")
		return
		
	if Engine.is_editor_hint():
		printerr("NAO PODE MUDAR O INVENTARIO SECUNDARIO SE JA TIVER ALGUM ATIVO")

func remove_secondary_inventory() -> void:
	if _secondary_inventory != null:
		_secondary_inventory = null
		secondary_inventory_changed.emit(null)
		return
		
	if Engine.is_editor_hint():
		printerr("NAO PODE REMOVER O INVENTARIO SECUNDARIO SE JA NAO TER ALGUM ATIVO")

func check_stack_exists(stack: ItemStack) -> bool:
	if not is_instance_valid(stack):
		return false
	
	var primary_has = _primary_inventory != null and _primary_inventory.stacks.has(stack)
	var secondary_has = _secondary_inventory != null and _secondary_inventory.stacks.has(stack)
	
	return primary_has or secondary_has

func change_item_on_stack_for_other(stack_out :ItemStack, stack_in:ItemStack) -> void:
	if stack_out == null or stack_in == null:
		return
		
	if not check_stack_exists(stack_out) and not check_stack_exists(stack_in):
		if Engine.is_editor_hint():
			printerr("Alguma das stacks origem ou destino nao existe nos inventarios ativos")
		return
	
	var out_item = stack_out.item
	var out_qty = stack_out.quantity
	
	var in_item = stack_in.item
	var in_qty = stack_in.quantity
	
	if out_item != null and in_item != null and out_item.is_equal(in_item):
		leave_it_stacked(stack_out,out_item,out_qty,stack_in,in_item,in_qty)
	else:
		swap(stack_out,out_item,out_qty,stack_in,in_item,in_qty)

func leave_it_stacked(stack_out:ItemStack,out_item:Item,out_qty:int,stack_in:ItemStack,in_item:Item,in_qty:int):
	var remaining_from_out: int = stack_in.push_item(out_item, out_qty)
		
	if remaining_from_out > 0:
		stack_out.reset_quantity()
		stack_out.push_item(out_item, remaining_from_out)
	else :
		stack_out.reset(true)

func swap(stack_out:ItemStack,out_item:Item,out_qty:int,stack_in:ItemStack,in_item:Item,in_qty:int):
	stack_in.swap_item(out_item, out_qty)
	stack_out.swap_item(in_item, in_qty)
