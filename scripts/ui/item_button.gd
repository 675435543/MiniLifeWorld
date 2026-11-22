class_name ItemButton
extends Button
## 道具栏按钮：绘制道具图标，按下（button_down）立即生成可拖动道具。


@export var item_id := ""

var _data: Dictionary = {}


func _ready() -> void:
	flat = true
	custom_minimum_size = Vector2(120, 150)
	_data = GameData.items.get(item_id, {})
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	draw_set_transform(Vector2(size.x * 0.5, size.y * 0.62), 0.0, Vector2(1.3, 1.3))
	match item_id:
		"food":
			Item.draw_icon_food(self, _data)
		"water_cup":
			Item.draw_icon_cup(self, _data)
		"clothes":
			Item.draw_icon_clothes(self, _data)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_string(ThemeDB.fallback_font, Vector2(0, size.y - 8), str(_data.get("name", item_id)), HORIZONTAL_ALIGNMENT_CENTER, size.x, 22, Color(0.364, 0.251, 0.157))
