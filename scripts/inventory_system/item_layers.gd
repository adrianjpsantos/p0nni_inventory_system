extends RefCounted
class_name ItemLayers # Útil para acessar o enum a partir de qualquer script

enum ItemType {
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
