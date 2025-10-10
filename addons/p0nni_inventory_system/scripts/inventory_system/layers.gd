extends RefCounted
class_name Layers # Útil para acessar o enum a partir de qualquer script

enum Item {
	# 0. Itens sem função específica, usados para troca ou fabricação (crafting)
	MISC,           # Variados / Lixo
	CRAFTING_MATERIAL, # Materiais (madeira, minério, tecido)
	
	# 1. Equipamentos
	WEAPON,         # Espadas, arcos, machados
	ARMOR,          # Armaduras, elmos, botas (em geral)
	ACCESSORY,      # Anéis, amuletos, capas
	TOOL,           # Ferramentas (picareta, pá, machado de corte)
	
	# 2. Consumíveis (Itens que desaparecem após o uso)
	POTION,         # Poções (cura, mana, buff)
	FOOD,           # Comida (restaura HP/Mana, buffs temporários)
	SCROLL,         # Pergaminhos (magias de uso único)
	
	# 3. Chaves e Missão
	KEY,            # Chaves (para portas específicas)
	QUEST_ITEM,     # Itens necessários para progresso de missões
	
	# 4. Outros
	CURRENCY,       # Moeda do jogo (ouro, gemas)
	PET_OR_SUMMON,  # Itens que ativam um pet ou summon
}

enum Inventory {
	# ----------------------------------------------------
	# 1. LAYERS DE JOGADOR (Equipamento, Inventário Pessoal)
	# ----------------------------------------------------
	
	# Inventário principal (Mochila)
	PLAYER_INVENTORY,
	# Slots dedicados ao equipamento do personagem (Armadura, Anéis, etc.)
	PLAYER_EQUIPMENT,
	# Espaços de acesso rápido (Hotbar)
	PLAYER_QUICK_SLOT,
	# Espaço de forja/criação
	PLAYER_CRAFTING_GRID,
	
	# ----------------------------------------------------
	# 2. LAYERS DE CONTAINER (Armazenamento, Containers no Mundo)
	# ----------------------------------------------------
	
	# Baús e containers estáticos no mundo (Chest, Vault)
	CONTAINER_STORAGE,
	# Inventários de NPCs ou Vendedores
	CONTAINER_VENDOR,
	# Máquinas ou estações de processamento (Forja, etc.)
	CONTAINER_MACHINE,
	
	# ----------------------------------------------------
	# 3. LAYERS TEMPORÁRIAS E DE SISTEMA
	# ----------------------------------------------------
	
	# Item acabou de ser derrubado no mundo (Drop)
	WORLD_DROP,
	# Item sendo arrastado com o mouse (Drag-and-Drop)
	TEMPORARY_DRAG,
	# Itens em um estado intermediário/de transação
	TEMPORARY_TRANSFER,
	# Slots genéricos, sem regras específicas (Misc/Default)
	SYSTEM_MISC,
	
	# ----------------------------------------------------
	# 4. LAYERS DE COMBATE/EFEITOS
	# ----------------------------------------------------
	
	# Inventário de um cadáver/loot
	CORPSE_LOOT,
	# Inventário de munição ou consumíveis ativos
	ACTIVE_CONSUMABLE,
}
