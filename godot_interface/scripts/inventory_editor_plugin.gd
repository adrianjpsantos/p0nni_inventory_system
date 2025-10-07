# res://addons/p0nni_inventory_system/scripts/item_editor_plugin.gd
@tool
extends EditorInspectorPlugin

# A função mais importante: Diz ao Godot quais objetos (recursos) este plugin deve manipular.
# Se retornar true, o Inspector usará este plugin, se não, usará o padrão.
func can_handle(object: Object) -> bool:
	# Verifica se o objeto herda da sua classe base Item (assumindo class_name Item)
	return object is Inventory

# Opcional: Aqui você pode adicionar controles personalizados ACIMA das propriedades nativas.
# func _process_unhandled_key(object: Object, property: String, type: int, hint: int, hint_string: String, usage_flags: int, wide: bool):
#     if property == "image":
#         # Adiciona um botão ou pré-visualização personalizada ao lado da propriedade 'image'
#         # add_custom_row(my_custom_node)
#         return true
#     return false
