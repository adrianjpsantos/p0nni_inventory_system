@tool
extends EditorPlugin
	
var item_tab_dock: Control
var item_inspector_plugin: EditorInspectorPlugin

func _enter_tree():
	# Carrega a cena do seu painel Dock (que contém a ItemList)
	var items_tab_scene = preload("res://addons/p0nni_inventory_system/godot_interface/items_tab.tscn")
	item_tab_dock = items_tab_scene.instantiate()
	
	# Adiciona o Dock à área de editor
	add_control_to_dock(DOCK_SLOT_LEFT_UR, item_tab_dock,null)
	
	# --- ADIÇÃO DO EDITOR INSPECTOR PLUGIN ---
	# Instancia o script que ensina o Inspector a editar o Item (Opcional, mas recomendado)
	item_inspector_plugin = preload("res://addons/p0nni_inventory_system/godot_interface/scripts/item_editor_plugin.gd").new()
	add_inspector_plugin(item_inspector_plugin)

func _exit_tree():
	# Remove tudo para limpar o editor
	remove_control_from_docks(item_tab_dock)
	item_tab_dock.queue_free()
	
	remove_inspector_plugin(item_inspector_plugin)
