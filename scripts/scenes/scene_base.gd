extends Control
## 场景基类：显示场景名，提供「返回地图」按钮。
## M0 阶段各场景为占位房间；M2 起承载角色与道具。

@export var scene_id := ""


func _ready() -> void:
	var info: Dictionary = GameData.scenes.get(scene_id, {})
	var title_label := get_node_or_null("TitleLabel") as Label
	if title_label:
		title_label.text = str(info.get("name", "场景"))
	var back_btn := get_node_or_null("BackButton") as Button
	if back_btn:
		back_btn.pressed.connect(_on_back)
	else:
		push_error("场景缺少 BackButton 节点: " + scene_id)


func _on_back() -> void:
	SceneManager.go_to_map()
