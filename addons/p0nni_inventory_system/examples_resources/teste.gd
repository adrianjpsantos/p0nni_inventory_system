# main_test.gd
extends Node3D

@onready var player_inventory_container = $PlayerInventory
@onready var chest_inventory_container = $ChestInventory

func _ready():
	# Certifique-se de que os containers foram encontrados
	if player_inventory_container == null or chest_inventory_container == null:
		printerr("ERRO: Um ou ambos os InventoryContainers não foram encontrados na cena!")
		return

	Inventories.set_primary_inventory(player_inventory_container.inventory)

func _input(event: InputEvent) -> void:
	# Adicionamos um print para garantir que a tecla está sendo detectada.
	if event.is_action_pressed("ui_accept"):
		print("Ação 'ui_accept' pressionada.") # <-- LINHA DE DEBUG
		
		player_inventory_container.inventory.inventory_changed.emit()
		if Inventories.get_secondary() == null:
			print("Abrindo baú")
			Inventories.set_secondary_inventory(chest_inventory_container.inventory)
		else:
			print("Fechando baú")
			Inventories.remove_secondary_inventory()
