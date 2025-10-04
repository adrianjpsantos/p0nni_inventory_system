@tool
extends EditorPlugin


const MainPanel = preload("res://addons/p0nni_inventory_system/godot_interface/main.tscn")
const MAIN_ICON = preload("res://addons/p0nni_inventory_system/godot_interface/icons/main.svg")

var main_panel_instance


func _enter_tree():
	main_panel_instance = MainPanel.instantiate()
	# Add the main panel to the editor's main viewport.
	EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	# Hide the main panel. Very much required.
	_make_visible(false)


func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible


func _get_plugin_name():
	return "Inventories"


func _get_plugin_icon():
	const ICON_SIZE = 16
 # 1. Carrega o SVG original como uma Texture2D
	var svg_texture: Texture2D = MAIN_ICON
	
	# 2. Verifica se o SVG precisa ser redimensionado e se é um Texture2D (deve ser após o preload)
	if svg_texture:
		# Se você quer garantir o tamanho exato, pode criar um Image a partir da textura
		# e depois criar um ImageTexture redimensionada.
		
		# A maneira mais simples (e que funciona com preloads) é usar a função de 
		# redimensionamento da Image
		var image = svg_texture.get_image()
		
		# Redimensiona a imagem se o tamanho não for o desejado
		if image.get_width() != ICON_SIZE or image.get_height() != ICON_SIZE:
			# Redimensiona a imagem para o tamanho desejado (ex: 32x32)
			# Usa INTERPOLATE_NEAREST para imagens pixeladas, ou INTERPOLATE_LINEAR
			# para SVGs ou imagens mais suaves.
			image.resize(ICON_SIZE, ICON_SIZE, Image.INTERPOLATE_BILINEAR)
			
			# Converte a Image redimensionada de volta para um ImageTexture
			var new_texture = ImageTexture.create_from_image(image)
			return new_texture
			
		return svg_texture # Retorna a original se já estiver no tamanho certo
	return null
