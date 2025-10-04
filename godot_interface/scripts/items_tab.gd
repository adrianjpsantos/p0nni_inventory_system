@tool
extends Node

@export var filter_items_name : LineEdit
@export var filter_items_layer_dropdown : MenuButton
@export var item_list : ItemList

var items:Array[Item]
var current_filter_layer: String = "All"

const ITEM_BASE_SCRIPT_PATH = "res://addons/p0nni_inventory_system/scripts/inventory_system/item.gd"
const ITEM_RESOURCES_PATH = "res://resources/inventories/items/"
const ITEM_BASE_CLASS = "Item"

func _ready() -> void:
	_populate_layer_dropdown()
	refresh_item_list()
	filter_items_name.text_changed.connect(_on_item_filter_name_changed)
	filter_items_layer_dropdown.get_popup().index_pressed.connect(_on_filter_layer_changed)
	if not item_list.item_clicked.is_connected(_on_item_clicked):
		item_list.item_clicked.connect(_on_item_clicked)

func _on_filter_layer_changed(index:int)->void:
	current_filter_layer  = filter_items_layer_dropdown.get_popup().get_item_text(index)
	print(current_filter_layer)
	_apply_all_filters()
func _apply_all_filters():
	var search_name = filter_items_name.text
	var layer_name = current_filter_layer
	
	var filtered_items: Array[Item] = items.filter(
		func(item):
			# 🚨 Proteção essencial contra placeholders
			if not is_instance_valid(item):
				return false
				
			print(item.layer)
				
			# 1. Filtro por Nome
			if not search_name.is_empty():
				# Verifica se a propriedade existe antes de acessar (proteção extra)
				if not ("name" in item and item.name.to_lower().contains(search_name.to_lower())):
					return false # Não passou no filtro de nome
					
			# 2. Filtro por Camada
			if layer_name != "All":
				# Proteção contra placeholder ANTES de chamar o método
				if item.has_method("get_layer_name"):
					var item_layer = item.layer
					if item_layer != layer_name:
						return false # Não passou no filtro de camada
				else:
					# Se não tiver o método, o item não pertence à camada válida
					return false
					
			return true # Passou em todos os filtros
	)
	
	_update_list_view(filtered_items)

func _on_item_filter_name_changed(new_text:String)->void:
	_apply_all_filters()

func reload_item_resources():
	items = load_items(ITEM_RESOURCES_PATH, ITEM_BASE_CLASS)

func refresh_item_list(_filter_name: String = "All"):
	reload_item_resources()
	_update_list_view(items)
			
func load_items(path: String, base_class_name: String) -> Array[Item]:
	var item_resources: Array[Item] = []
	var dir = DirAccess.open(path)
	
	# 1. Carrega o SCRIPT base de forma confiável
	var base_script: Script = load(ITEM_BASE_SCRIPT_PATH)
	if base_script == null:
		printerr("ERRO: Não foi possível carregar o script base em: " + ITEM_BASE_SCRIPT_PATH)
		return item_resources

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres") and not dir.current_is_dir():
				var full_path = path.path_join(file_name)
				
				var resource: Resource = load(full_path)
				
				if resource:
					var is_valid_type = false
					var resource_script: Script = resource.get_script()
					
					if resource_script != null:
						# Inicializa a busca com o script do recurso (ex: ItemTool.gd)
						var current_script = resource_script
						
						# 2. Percorre a cadeia de herança do script
						while current_script != null:
							if current_script == base_script:
								# Encontrou o script base (Item.gd)!
								is_valid_type = true
								break
							
							# Sobe para o pai (ex: ItemTool.gd -> Item.gd)
							current_script = current_script.get_base_script()

					if is_valid_type:
						# Faz o cast de segurança, pois sabemos que é um Item válido
						var item_cast: Item = resource
						item_resources.append(item_cast)
						
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		printerr("Não foi possível abrir o diretório de recursos: " + path)
		
	return item_resources
func _on_item_clicked(index: int, at_position: Vector2, mouse_button_index: int):
	# Obtém o recurso clicado usando o índice da ItemList
	if index >= 0 and index < items.size():
		var selected_item: Resource = items[index]
		print("Item Clicado: " + selected_item.name)
		# Aqui você chamaria a função que carrega os dados para o painel de edição
		# _load_item_resource_to_ui(selected_item)

func _update_list_view(resources_to_display: Array[Item]):
	item_list.clear()
	for item in resources_to_display:
		var item_name: String = item.name if "name" in item else "Item Desconhecido"
		var item_icon: Texture2D = item.image if "image" in item else null 
		item_list.add_item(item_name, item_icon)

func _populate_layer_dropdown():
	# Este é um exemplo de como preencher o MenuButton (ajuste conforme a necessidade)
	var popup = filter_items_layer_dropdown.get_popup()
	popup.clear()
	popup.add_item("All")
	popup.add_item("Tool")
	popup.add_item("Misc")
