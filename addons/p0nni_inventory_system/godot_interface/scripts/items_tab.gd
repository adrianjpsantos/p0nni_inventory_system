@tool
extends Control

@export var filter_items_name : LineEdit
@export var filter_items_layer_dropdown : MenuButton
@export var orderer_items_button : Button
@export var reload_items_button : Button
@export var item_list : ItemList

var _connected_items: Array[Item] = []
var current_filter_layer:String = "ALL"
var order_item = "DESC"

const ITEM_BASE_SCRIPT_PATH = "res://addons/p0nni_inventory_system/scripts/inventory_system/item.gd"
const ITEM_RESOURCES_PATH = "res://resources/inventories/items/"
const ITEM_BASE_CLASS = "Item"


func _ready() -> void:
	if Engine.is_editor_hint():
		_populate_layer_dropdown()
		refresh_item_list()
	
		orderer_items_button.pressed.connect(_on_orderer_items_button_clicked)
		reload_items_button.pressed.connect(refresh_item_list)
		filter_items_name.text_changed.connect(_on_item_filter_name_changed)
		filter_items_layer_dropdown.get_popup().index_pressed.connect(_on_filter_layer_changed)
		if not item_list.item_clicked.is_connected(_on_item_clicked):
			item_list.item_clicked.connect(_on_item_clicked)

func _on_item_resource_changed():
	refresh_item_list()

func _on_orderer_items_button_clicked():
	if order_item == "DESC":
		order_item = "ASC"
	else:
		order_item = "DESC"
		
	_apply_all_filters()

func _on_filter_layer_changed(index:int)->void:
	current_filter_layer  = filter_items_layer_dropdown.get_popup().get_item_text(index)
	print(current_filter_layer)
	_apply_all_filters()
	
func _apply_all_filters():
	var search_name = filter_items_name.text
	var layer_name = current_filter_layer
	
	_connected_items.sort_custom(
		func(a: Item, b: Item):
			# Obtém os nomes em minúsculas para comparação sem distinção de maiúsculas/minúsculas
			var name_a = a.name.to_lower()
			var name_b = b.name.to_lower()
			
			if order_item == "ASC":
				# Ordenação ASC (A -> Z): 'a' vem antes de 'b' se 'a' < 'b'
				return name_a < name_b
			else:
				# Ordenação DESC (Z -> A): 'a' vem antes de 'b' se 'a' > 'b'
				return name_a > name_b
	)
	
	var filtered_items: Array[Item] = _connected_items.filter(
		func(item:Item):
			
			if not is_instance_valid(item):
				return false
				
			# ... (Filtro por nome, sem alterações) ...
					
			# 2. Filtro por Camada
			if layer_name != "ALL":
				
				# 1. Acessa a propriedade 'layer' do item (que é um inteiro do enum: 0, 1, 2...)
				var item_layer = item.get("layer") # Ex: 3 (que seria o valor de "TOOL")
				
				# 2. CONVERSÃO CORRETA: Usa o valor int como índice no array de chaves do enum
				var layer_name_to_compare = Layers.Item.keys()[item_layer] # Ex: "TOOL"
				
				print("Item Layer (INT): ", item_layer)
				print("Layer Name (STRING): ", layer_name_to_compare)
				
				# 3. Comparação final (ambas são Strings em MAIÚSCULAS)
				if layer_name_to_compare != layer_name:
					return false # Não passou no filtro de camada
					
			return true # Passou em todos os filtros
	)

	
	_update_list_view(filtered_items)

func _on_item_filter_name_changed(new_text:String)->void:
	_apply_all_filters()

func refresh_item_list():
	# 1. 🧹 LIMPEZA: Desconecta o sinal 'changed' de todos os itens anteriores
	# Isso evita que o sinal seja disparado várias vezes para o mesmo item.
	for item in _connected_items:
		if is_instance_valid(item) and item.changed.is_connected(_on_item_resource_changed):
			item.changed.disconnect(_on_item_resource_changed)
	_connected_items.clear()
	
	# 2. 🔄 CARREGAMENTO: Recarrega todos os recursos (sua função atual)
	var all_items = load_items() # <--- Use sua função interna de carregamento
	
	# 3. 🔌 CONEXÃO: Conecta o sinal 'changed' em cada novo item
	for item in all_items:
		if is_instance_valid(item) and not item.changed.is_connected(_on_item_resource_changed):
			item.changed.connect(_on_item_resource_changed)
			_connected_items.append(item)
			
	# 4. 🎨 UI: Aplica filtros e atualiza a ItemList com os dados mais recentes
	_update_list_view(_connected_items)
	
func load_items() -> Array[Item]:
	var item_resources: Array[Item] = []
	var dir = DirAccess.open(ITEM_RESOURCES_PATH)
	
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
				var full_path = ITEM_RESOURCES_PATH.path_join(file_name)
				
				# --- MUDANÇA CRÍTICA AQUI ---
				# Usamos ResourceLoader.load() para carregamento síncrono.
				var resource: Resource = ResourceLoader.load(full_path)
				
				if resource and resource is Item:
					var is_valid_type = false
					var resource_script: Script = resource.get_script()
					
					# Se o recurso for carregado mas o script ainda for um placeholder (o que causa o erro), 
					# fazemos uma verificação mais profunda.
					if resource_script == null and resource.get_class() != "Resource":
						# Se não tem script, mas não é a classe base Resource, algo deu errado. Ignoramos por segurança.
						is_valid_type = false
					elif resource_script != null:
						var current_script = resource_script
						# 2. Percorre a cadeia de herança do script
						while current_script != null:
							if current_script == base_script:
								is_valid_type = true
								break
							current_script = current_script.get_base_script()
					
					# NOTE: A verificação "resource is Item" geralmente já é suficiente se 
					# os scripts ItemBase e ItemTool tiverem class_name.
					
					if is_valid_type:
						item_resources.append(resource as Item)
						
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		printerr("Não foi possível abrir o diretório de recursos: " + ITEM_RESOURCES_PATH)
		
	return item_resources
func _on_item_clicked(index: int, at_position: Vector2, mouse_button_index: int):
	# Obtém o recurso clicado usando o índice da ItemList
	if index >= 0 and index < _connected_items.size():
		var selected_item: Resource = _connected_items[index]
		
		# --- AQUI ESTÁ A MUDANÇA CRÍTICA ---
		
		# 1. Obtém a interface do Editor (só funciona em modo @tool)
		var editor = EditorInterface
		
		if editor:
			# 2. Diz ao Editor para abrir e editar este recurso no Inspector
			editor.edit_resource(selected_item)
			print("Item selecionado e enviado ao Inspector: ", selected_item.name)
		else:
			# Isso só acontece se não estiver no editor
			print("Item Clicado: " + selected_item.name)

func _update_list_view(resources_to_display: Array[Item]):
	item_list.clear()
	for item in resources_to_display:
		var item_name: String = item.name if "name" in item else "Item Desconhecido"
		var item_icon: Texture2D = item.image if "image" in item else null 
		item_list.add_item(item_name, item_icon)

func _populate_layer_dropdown():
	# Este é um exemplo de como preencher o MenuButton (ajuste conforme a necessidade)
	var popup = filter_items_layer_dropdown.get_popup()
	var layers_keys = Layers.Item.keys()
	popup.clear()
	popup.add_item("ALL")
	for key in layers_keys:
		popup.add_item(key)
