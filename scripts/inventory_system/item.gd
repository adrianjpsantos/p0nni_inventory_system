@icon("res://addons/p0nni_inventory_system/scripts/script_icons/item.svg")
extends Resource
class_name Item

@export var name : String
@export var description: String
@export var image : Texture2D
@export var max_per_stack: int = 1
@export var layer : Layers.Item = Layers.Item.MISC

func _init() -> void:
	if not self is Item and layer == Layers.Item.MISC:
		printerr("PLEASE OVERRIDE INIT FUNCTION ON YOUR CUSTOM ITEM, AND SET A LAYER")
		return



func is_equal(other_item: Item) -> bool:
	return self.resource_path == other_item.resource_path


## Método _to_string()
# --------------------
# Chamado automaticamente quando você usa `print(instancia_do_item)`
func _to_string() -> String:
	# Formata uma string que contém as informações chave do seu item
	var image_name = image.resource_path if image else "Nenhuma Imagem"
	
	var info_string = \
"""
== Detalhes do Item ==
Nome:          %s
Descrição:     %s
Empilhável até: %d
Camada (Layer):  %s
Caminho Imagem:  %s
=======================
""" % [
		name,
		description,
		max_per_stack,
		Layers.Item.keys()[layer] if Layers.Item.keys().size() > layer else str(layer),
		image_name
	]
	
	return info_string
