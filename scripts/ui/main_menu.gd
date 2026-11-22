extends Control
## 主菜单：点击「开始游戏」进入世界地图。


func _ready() -> void:
	var start_btn := get_node_or_null("Center/VBox/StartButton") as Button
	if start_btn:
		start_btn.pressed.connect(_on_start)
	else:
		push_error("主菜单缺少 StartButton 节点")


func _on_start() -> void:
	SceneManager.go_to_map()
