@tool
extends Control

@export var filter_inventories_name : LineEdit
@export var filter_inventories_layer_dropdown : MenuButton
@export var orderer_inventories_button : Button
@export var reload_inventories_button : Button
@export var inventories_list : ItemList

var _connected_inventories: Array[Inventory] = []
var current_filter_layer:String = "ALL"
var order_inventory = "DESC"

const INVENTORY_BASE_SCRIPT_PATH = "res://addons/p0nni_inventory_system/scripts/inventory_system/inventory.gd"
const INVENTORY_RESOURCES_PATH = "res://resources/inventories/inventory/"
const INVENTORY_BASE_CLASS = "Inventory"


func _ready() -> void:
	if Engine.is_editor_hint():
		_populate_layer_dropdown()
		refresh_inventories_list()
		
		orderer_inventories_button.pressed.connect(_on_orderer_inventories_button_clicked)
		reload_inventories_button.pressed.connect(refresh_inventories_list)
		filter_inventories_name.text_changed.connect(_on_inventory_filter_name_changed)
		
		filter_inventories_layer_dropdown.get_popup().index_pressed.connect(_on_filter_layer_changed)
		if not inventories_list.item_clicked.is_connected(_on_inventory_clicked):
			inventories_list.item_clicked.connect(_on_inventory_clicked)

func _on_inventory_resource_changed():
	refresh_inventories_list()

func _on_orderer_inventories_button_clicked():
	if order_inventory == "DESC":
		order_inventory = "ASC"
	else:
		order_inventory = "DESC"
		
	_apply_all_filters()

func _on_filter_layer_changed(index:int)->void:
	current_filter_layer  = filter_inventories_layer_dropdown.get_popup().get_item_text(index)
	print(current_filter_layer)
	_apply_all_filters()
	
func _apply_all_filters():
	var search_name = filter_inventories_name.text
	var layer_name = current_filter_layer
	
	_connected_inventories.sort_custom(
		func(a: Inventory, b: Inventory):
			# Obtém os nomes em minúsculas para comparação sem distinção de maiúsculas/minúsculas
			var name_a = a.name.to_lower()
			var name_b = b.name.to_lower()
			
			if order_inventory == "ASC":
				# Ordenação ASC (A -> Z): 'a' vem antes de 'b' se 'a' < 'b'
				return name_a < name_b
			else:
				# Ordenação DESC (Z -> A): 'a' vem antes de 'b' se 'a' > 'b'
				return name_a > name_b
	)
	
	var filtered_inventories: Array[Inventory] = _connected_inventories.filter(
		func(inventory:Inventory):
			
			if not is_instance_valid(Inventory):
				return false
				
			# ... (Filtro por nome, sem alterações) ...
					
			# 2. Filtro por Camada
			if layer_name != "ALL":
				
				# 1. Acessa a propriedade 'layer' do item (que é um inteiro do enum: 0, 1, 2...)
				var inventory_layer = inventory.get("layer") # Ex: 3 (que seria o valor de "TOOL")
				
				# 2. CONVERSÃO CORRETA: Usa o valor int como índice no array de chaves do enum
				var layer_name_to_compare = Layers.Inventory.keys()[inventory_layer] # Ex: "TOOL"
				
				print("Layer Name (STRING): ", layer_name_to_compare)
				
				# 3. Comparação final (ambas são Strings em MAIÚSCULAS)
				if layer_name_to_compare != layer_name:
					return false # Não passou no filtro de camada
					
			return true # Passou em todos os filtros
	)

	
	_update_list_view(filtered_inventories)

func _on_inventory_filter_name_changed(new_text:String)->void:
	_apply_all_filters()

func refresh_inventories_list():
	# 1. 🧹 LIMPEZA: Desconecta o sinal 'changed' de todos os itens anteriores
	# Isso evita que o sinal seja disparado várias vezes para o mesmo item.
	for inventory in _connected_inventories:
		if is_instance_valid(inventory) and inventory.changed.is_connected(_on_inventory_resource_changed):
			inventory.changed.disconnect(_on_inventory_resource_changed)
	_connected_inventories.clear()
	
	# 2. 🔄 CARREGAMENTO: Recarrega todos os recursos (sua função atual)
	var all_inventories = load_inventories() # <--- Use sua função interna de carregamento
	
	# 3. 🔌 CONEXÃO: Conecta o sinal 'changed' em cada novo item
	for inventory in all_inventories:
		if is_instance_valid(inventory) and not inventory.changed.is_connected(_on_inventory_resource_changed):
			inventory.changed.connect(_on_inventory_resource_changed)
			_connected_inventories.append(inventory)
			
	# 4. 🎨 UI: Aplica filtros e atualiza a ItemList com os dados mais recentes
	_update_list_view(_connected_inventories)
	
func load_inventories() -> Array[Inventory]:
	var inventory_resources: Array[Inventory] = []
	var dir = DirAccess.open(INVENTORY_RESOURCES_PATH)
	
	# 1. Carrega o SCRIPT base de forma confiável
	var base_script: Script = load(INVENTORY_BASE_SCRIPT_PATH)
	if base_script == null:
		printerr("ERRO: Não foi possível carregar o script base em: " + INVENTORY_BASE_SCRIPT_PATH)
		return inventory_resources

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres") and not dir.current_is_dir():
				var full_path = INVENTORY_RESOURCES_PATH.path_join(file_name)
				
				# --- MUDANÇA CRÍTICA AQUI ---
				# Usamos ResourceLoader.load() para carregamento síncrono.
				var resource: Resource = ResourceLoader.load(full_path)
				
				if resource and resource is Inventory:
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
					
					if is_valid_type:
						inventory_resources.append(resource as Inventory)
						
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		printerr("Não foi possível abrir o diretório de recursos: " + INVENTORY_RESOURCES_PATH)
		
	return inventory_resources
	
func _on_inventory_clicked(index: int, at_position: Vector2, mouse_button_index: int):
	# Obtém o recurso clicado usando o índice da ItemList
	if index >= 0 and index < _connected_inventories.size():
		var selected_item: Resource = _connected_inventories[index]
		
		# --- AQUI ESTÁ A MUDANÇA CRÍTICA ---
		
		# 1. Obtém a interface do Editor (só funciona em modo @tool)
		var editor = EditorInterface
		
		if editor:
			# 2. Diz ao Editor para abrir e editar este recurso no Inspector
			editor.edit_resource(selected_item)
			print("Inventario selecionado e enviado ao Inspector: ", selected_item.name)
		else:
			# Isso só acontece se não estiver no editor
			print("Inventario Clicado: " + selected_item.name)

func _update_list_view(resources_to_display: Array[Inventory]):
	inventories_list.clear()
	for inventory in resources_to_display:
		var inventory_id: String = inventory.uid if "uid" in inventory else "Inventario Desconhecido"
		var inventory_title: String = inventory.title if "title" in inventory else "Inventario sem Titulo"
		var inventory_icon: Texture2D = inventory.custom_icon if "custom_icon" in inventory else null

		inventories_list.add_item(inventory_id + " : " + inventory_title, inventory_icon)

func _populate_layer_dropdown():
	# Este é um exemplo de como preencher o MenuButton (ajuste conforme a necessidade)
	var popup = filter_inventories_layer_dropdown.get_popup()
	var layers_keys = Layers.Inventory.keys()
	popup.clear()
	popup.add_item("ALL")
	for key in layers_keys:
		popup.add_item(key)
