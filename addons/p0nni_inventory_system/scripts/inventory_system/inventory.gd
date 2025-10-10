@icon("res://addons/p0nni_inventory_system/scripts/script_icons/inventory.svg")
extends Resource
class_name Inventory

@export var uid : String = "NO ID"
@export var title: String = "NO TITLE"
@export var custom_icon : Texture2D
var layer = Layers.Inventory.SYSTEM_MISC
@export var stacks : Array[ItemStack] = []

signal inventory_changed

func is_uid_valid() -> bool:
	return uid != "NO ID" and not uid.is_empty()

func print_inventory():
	if uid == "NO ID" and OS.has_feature("editor"):
		printerr("INVENTARIO " + Layers.Inventory.find_key(layer) + " SEM ID! Corrija a inicialização. ")
		
func push_item_on_stacks(i: Item,qty: int) -> int:
	var quantity_to_push: int = qty
	
	for stack in stacks:
		quantity_to_push = stack.push_item(i,quantity_to_push)
		if quantity_to_push == 0:
			break
	
	
	inventory_changed.emit()
	return quantity_to_push;
	
	
# Esta função concentra todas as checagens de validação que exigem CORREÇÃO MANUAL.
func validate_editor_data_integrity():
		
	var resource_path_info = "Resource: " + (resource_path if resource_path else "NOVO/NÃO SALVO")
	var needs_fix = false

	# --- A. CHECAGEM DE CONFIGURAÇÃO (PID) ---
	if uid == "NO ID" or uid.is_empty():
		printerr("⚠️ ERRO CRÍTICO (CONFIG): O Inventory Resource precisa de um 'uid' único definido. %s" % resource_path_info)
		needs_fix = true

	# --- B. CHECAGEM DE SLOTS ---
	if stacks.size() <= 0:
		printerr("⚠️ ERRO CRÍTICO (CONFIG): O 'STACKS' deve ser maior que zero. %s" % resource_path_info)
		needs_fix = true

	# --- C. CHECAGEM DE INTEGRIDADE DO ARRAY (NULLS) ---
	var null_count = 0
	var invalid_count = 0
	
	for stack in stacks:
		if stack == null:
			null_count += 1
			needs_fix = true
		elif not is_instance_valid(stack):
			invalid_count += 1
			needs_fix = true
			
	if null_count > 0 or invalid_count > 0:
		var integrity_msg = "⚠️ ERRO DE DADOS (INTEGRIDADE): O array 'stacks' possui %d nulo(s) e %d inválido(s). %s" % [null_count, invalid_count, resource_path_info]
		integrity_msg += "\n   Ajuste o array 'stacks' no Inspector, remova os itens nulos e salve o resource."
		printerr(integrity_msg)
		
	if needs_fix and resource_path.is_empty():
		printerr("⚠️ SALVE ESTE RESOURCE para que as configurações entrem em vigor.")
		
	var seen_stacks = {}
	var duplicate_count = 0
	
	for i in range(stacks.size()):
		var stack = stacks[i]
		
		# Ignora stacks nulas ou inválidas (já checado em C) [cite: 15]
		if not is_instance_valid(stack):
			continue
			
		# Usa o ID de objeto como chave
		var stack_id = stack.get_instance_id() 
		
		if seen_stacks.has(stack_id):
			printerr("⚠️ ERRO DE DADOS (DUPLICAÇÃO): O ItemStack %s é uma DUPLICATA. Indices: %s e %s." % [stack.resource_path, seen_stacks[stack_id], i])
			duplicate_count += 1
			needs_fix = true
		else:
			seen_stacks[stack_id] = i
			
	if duplicate_count > 0:
		printerr("⚠️ CORREÇÃO NECESSÁRIA: Remova a(s) entrada(s) duplicada(s) de ItemStack no array 'stacks' do Inspector e salve o resource.")
	
