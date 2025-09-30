# 📦 Sistema de Inventário Core (Data-Driven)

## 🌟 Visão Geral

Este é um sistema de inventário **Data-Driven** (orientado a dados) para Godot Engine, focado em fornecer uma lógica de gerenciamento de itens robusta e livre de bugs, como:

  * **Empilhamento** (Stacking) e Respeito ao limite `max_per_stack`.
  * **Troca Atômica** (Swapping) de itens entre slots.
  * **Transferência** entre inventários (Jogador/Baú).

**Princípio Fundamental:** O sistema separa a **Lógica de Dados** (classes `Item`, `ItemStack`, `Inventory`) da **Visualização** (sua UI). O código central de movimentação de itens é independente de botões, ícones ou painéis.

-----

## ⚙️ Configuração (Setup Inicial)

Para usar o sistema, apenas duas etapas são necessárias:

### 1\. Definir o `InventoriesController` como AutoLoad

O `InventoriesController` é o **Singleton (AutoLoad)** do sistema, fornecendo acesso global à API.

  * Vá em **Projeto** \> **Configurações do Projeto** \> **AutoLoad**.
  * Adicione o script `inventories_controller.gd`.
  * Defina o nome de nó global como **`Inventories`**.

Isto permite que você chame todas as funções do Core com `Inventories.<função>`.

### 2\. Inicializar o Inventário Principal

No script inicial do seu jogador ou gerenciador de jogo, você deve carregar seu recurso de inventário e registrá-lo no Controller.

```gdscript
# Exemplo de inicialização (Player.gd ou GameManager.gd)
extends Node

@export var player_inventory_resource: Inventory # Carregue seu .tres aqui

func _ready():
	# Registra o inventário principal do jogador no Core
	Inventories.set_primary_inventory(player_inventory_resource)
	
	# Exemplo: Como dar um item ao jogador (sem UI)
	var potion = preload("res://Items/HealthPotion.tres")
	var leftover = Inventories.get_primary().push_item_on_stacks(potion, 5)
	
	if leftover > 0:
		print("Ainda sobraram %d poções, o inventário estava cheio." % leftover)
```

-----

## 💾 Core da API: Classes de Dados (Resources)

As classes de dados são `Resource`s e são o coração do sistema. Elas devem ser manipuladas primariamente através dos métodos do `InventoriesController`.

### 1\. Item (`Item.gd`)

Recurso base para todos os itens do jogo. É a fonte de informação para a UI.

| Propriedade/Método | Tipo | Descrição |
| :--- | :--- | :--- |
| `@export var name` | `String` | Nome do item (para tooltips e UI). |
| `@export var max_per_stack`| `int` | **Limite de empilhamento** (ex: 1 para Espada, 99 para Poção). |
| `is_equal(other_item)` | `bool` | Checa se dois itens são iguais (usando `resource_path`). |

### 2\. ItemStack (`item_stack.gd`)

Representa um **slot individual** no inventário.

| Tipo | Nome | Descrição |
| :--- | :--- | :--- |
| **Propriedade** | `@export var item` | Referência ao Resource do `Item` que a pilha contém. |
| **Propriedade** | `@export var quantity`| A quantidade atual do item na pilha. |
| **Método** | `push_item(Item, qty) -> int` | **Empilhamento.** Adiciona o item à pilha. Retorna a quantidade que **sobra**. |
| **Método** | `swap_item(Item, qty)` | **Substituição atômica.** Sobrescreve `item` e `quantity`. Usado pelo Controller para Troca. |
| **Método** | `use_item()` | Decrementa `quantity` em 1 e limpa o slot se a quantidade chegar a zero. |
| **Método** | `reset(force: bool)` | Zera `quantity`. Se `force=true`, define `item = null` e `quantity = 0`. |
| **Sinal** | `stack_changed(stack: ItemStack)` | **CRÍTICO\!** Emitido sempre que `item` ou `quantity` mudam. **Sua UI de slot deve se conectar a este sinal**. |

### 3\. Inventory (`inventory.gd`)

O contêiner que armazena o array de `ItemStack`s.

| Método/Sinal | Tipo | Descrição |
| :--- | :--- | :--- |
| `@export var stacks` | `Array[ItemStack]` | O array de todos os slots de dados (configurados via Resource no Inspector). |
| `push_item_on_stacks(Item, qty)` | `int` | **Entrada de Item.** Tenta adicionar o item em todos os slots disponíveis. Retorna a sobra não adicionada. |

-----

## 🕹️ InventoriesController (AutoLoad: `Inventories`)

O orquestrador de toda a lógica de jogo.

| Método/Sinal | Descrição |
| :--- | :--- |
| `get_primary()`/`get_secondary()` | Acessa os objetos `Inventory` (Player / Baú, Loja, etc.). |
| `set_secondary_inventory(Inventory)` | Define um inventário externo para ser acessado pela UI (ex: abrir um baú). |
| `remove_secondary_inventory()` | Remove o inventário externo (ex: fechar o baú). |
| `change_item_on_stack_for_other(stack_out, stack_in)` | **Lógica Central de Interação (Clique/Arrasto).** Essa função decide o que acontece quando você clica em um slot, gerenciando Empilhamento, Troca e Limpeza. **Sua UI deve chamá-la.** |
| `signal primary_inventory_changed` | Emitido quando um novo inventário primário é definido. |
| `signal secondary_inventory_changed` | Emitido quando o inventário secundário é aberto ou fechado (envia `null` ao fechar). |

-----

## 🎨 Diretrizes para Criação de UI Customizada

O sistema de UI de exemplo (`InventorySlotUI`, `InventoryPanel`) deve ser descartado ou usado apenas como referência. Para construir sua UI customizada, siga este fluxo:

1.  **Crie seu Slot UI** (ex: `MyCustomSlot.tscn`):
	  * Deve ter uma variável que armazene uma referência a um `ItemStack`.
	  * Na função de inicialização, chame `my_item_stack.stack_changed.connect(_update_visuals)`.
2.  **Crie seu Gerador de Painel** (`MyPanel.gd`):
	  * Recebe um objeto `Inventory` (via `get_primary()` ou `get_secondary()`).
	  * Itera sobre o array `inventory.stacks`.
	  * Para cada `ItemStack` no array, instancia um `MyCustomSlot` e chama `my_custom_slot.set_stack(item_stack)`.
3.  **Lógica de Interação (Clique):**
	  * No seu script que gerencia os cliques (o equivalente ao `InventoriesControllerUI`), use:
		```gdscript
		# Quando um slot A (held_stack) é arrastado para um slot B (clicked_stack):
		Inventories.change_item_on_stack_for_other(held_stack.item_stack, clicked_stack.item_stack)

		# Sua responsabilidade: Forçar a atualização visual dos dois slots
		held_stack.update_visuals()
		clicked_stack.update_visuals()
		```
