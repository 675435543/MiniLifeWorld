class_name AvatarButton
extends Button
## 角色栏头像按钮：程序化绘制头像，点击后由房间生成该角色。


@export var char_id := ""

var _palette: Dictionary = {}
var _char_name := ""


func _ready() -> void:
	flat = true
	custom_minimum_size = Vector2(120, 150)
	var info: Dictionary = GameData.characters.get(char_id, {})
	_palette = info.get("palette", {})
	_char_name = str(info.get("name", char_id))
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	var skin := Color(str(_palette.get("skin", "#FFCC9C")))
	var hair := Color(str(_palette.get("hair", "#5D4037")))
	var shirt := Color(str(_palette.get("shirt", "#FF8A65")))
	var ink := Color(0.2, 0.13, 0.10)
	var cx := size.x * 0.5
	var cy := size.y * 0.40
	# 肩膀
	draw_circle(Vector2(cx, size.y * 0.88), 42.0, shirt)
	draw_circle(Vector2(cx, size.y * 0.94), 48.0, shirt)
	# 头
	draw_circle(Vector2(cx, cy - 4), 34.0, hair)
	draw_circle(Vector2(cx, cy), 30.0, skin)
	# 眼睛与嘴
	draw_circle(Vector2(cx - 11, cy - 6), 3.8, ink)
	draw_circle(Vector2(cx + 11, cy - 6), 3.8, ink)
	draw_arc(Vector2(cx, cy + 10), 8.0, deg_to_rad(20), deg_to_rad(160), 12, ink, 2.0)
	# 名字
	draw_string(ThemeDB.fallback_font, Vector2(0, size.y - 8), _char_name, HORIZONTAL_ALIGNMENT_CENTER, size.x, 22, Color(0.364, 0.251, 0.157))
