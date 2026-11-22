extends Node
## 交互系统（Autoload: InteractionManager）
## M0 阶段为占位框架；M2 起由场景/道具数据驱动角色状态。

## 交互类型（与 data/items.json 的 interaction 字段对应）
const INTERACTIONS := ["eat", "drink", "sit", "sleep", "read", "play", "use", "wear", "examine"]

## 道具 interaction 字段 -> 角色应进入的状态
var _state_map: Dictionary = {
	"eat": "eat",
	"drink": "eat",
	"sit": "sit",
	"sleep": "sleep",
	"read": "read",
	"play": "play",
	"use": "interact",
	"wear": "idle",
	"examine": "idle",
}


func state_for(interaction: String) -> String:
	return str(_state_map.get(interaction, "interact"))


func interact(_character: Node, _target: Node, _item_data: Dictionary = {}) -> void:
	# M2 起：根据 item_data.interaction 让角色进入对应状态并播放动作。
	pass
