class_name Item
extends PropDraw
## 可交互道具/家具（M2/M3/M4）。
## 家具静置在场景中，角色拖到热区触发互动；消耗品从道具栏拖到角色身上。

@export var item_id := ""

var data: Dictionary = {}


func _ready() -> void:
	data = GameData.items.get(item_id, {})
	var pt := str(data.get("prop_type", item_id))
	prop_type = pt if not pt.is_empty() else item_id
	super._ready()


func begin_drag() -> void:
	pass


func end_drag() -> void:
	pass


## 互动热区（房间坐标，以落点为中心向上展开）
func zone_rect() -> Rect2:
	var zs: Array = data.get("zone_size", [160, 100])
	var w := float(zs[0])
	var h := float(zs[1])
	return Rect2(global_position - Vector2(w * 0.5, h), Vector2(w, h))


func _draw() -> void:
	match prop_type:
		"food":
			draw_icon_food(self, data)
		"water_cup":
			draw_icon_cup(self, data)
		"clothes":
			draw_icon_clothes(self, data)
		"stethoscope":
			draw_icon_stethoscope(self, data)
		"medicine":
			draw_icon_medicine(self, data)
		"book":
			draw_icon_book(self, data)
		"pencil":
			draw_icon_pencil(self, data)
		"basketball":
			draw_icon_ball(self, data)
		"dish":
			draw_icon_dish(self, data)
		"juice":
			draw_icon_juice(self, data)
		"burger":
			draw_icon_burger(self, data)
		_:
			super._draw()


# ---------- 图标绘制（Item 与道具栏按钮共用） ----------

static func draw_icon_food(ci: CanvasItem, info: Dictionary) -> void:
	var tint := Color(str(info.get("color", "#FFB74D")))
	_draw_icon_shadow(ci)
	ci.draw_circle(Vector2(0, -18), 20.0, tint.lightened(0.25))
	ci.draw_rect(Rect2(-18, -24, 36, 8), Color(0.5, 0.35, 0.2))
	ci.draw_rect(Rect2(-16, -12, 32, 8), Color(0.78, 0.3, 0.25))


static func draw_icon_cup(ci: CanvasItem, info: Dictionary) -> void:
	var tint := Color(str(info.get("color", "#64B5F6")))
	_draw_icon_shadow(ci)
	ci.draw_rect(Rect2(-16, -36, 32, 30), tint)
	ci.draw_rect(Rect2(-20, -38, 40, 6), tint.darkened(0.15))
	ci.draw_rect(Rect2(-18, -32, 36, 4), Color(1, 1, 1, 0.6))
	ci.draw_arc(Vector2(18, -21), 10.0, -PI * 0.5, PI * 0.5, 12, tint.darkened(0.3), 4.0)


static func draw_icon_clothes(ci: CanvasItem, info: Dictionary) -> void:
	var tint := Color(str(info.get("shirt", "#80CBC4")))
	_draw_icon_shadow(ci)
	ci.draw_rect(Rect2(-16, -40, 32, 40), tint)
	ci.draw_rect(Rect2(-34, -40, 18, 14), tint)
	ci.draw_rect(Rect2(16, -40, 18, 14), tint)
	ci.draw_circle(Vector2(0, -38), 6.0, Color(1, 1, 1, 0.7))


static func draw_icon_stethoscope(ci: CanvasItem, info: Dictionary) -> void:
	var tint := Color(str(info.get("color", "#90A4AE")))
	_draw_icon_shadow(ci)
	ci.draw_arc(Vector2(0, -30), 16.0, PI * 0.15, PI * 0.85, 14, tint, 4.0)
	ci.draw_line(Vector2(-12, -22), Vector2(-2, 6), tint, 4.0)
	ci.draw_line(Vector2(12, -22), Vector2(2, 6), tint, 4.0)
	ci.draw_circle(Vector2(0, 14), 9.0, tint.lightened(0.3))


static func draw_icon_medicine(ci: CanvasItem, info: Dictionary) -> void:
	var tint := Color(str(info.get("color", "#E57373")))
	_draw_icon_shadow(ci)
	ci.draw_rect(Rect2(-14, -34, 28, 30), tint)
	ci.draw_rect(Rect2(-9, -42, 18, 8), tint.darkened(0.25))
	ci.draw_rect(Rect2(-12, -26, 24, 4), Color(1, 1, 1, 0.55))
	ci.draw_rect(Rect2(-3, -18, 6, 14), Color(1, 1, 1, 0.85))
	ci.draw_rect(Rect2(-7, -14, 14, 6), Color(1, 1, 1, 0.85))


static func draw_icon_book(ci: CanvasItem, info: Dictionary) -> void:
	var tint := Color(str(info.get("color", "#8D6E63")))
	_draw_icon_shadow(ci)
	ci.draw_rect(Rect2(-26, -34, 52, 34), tint)
	ci.draw_rect(Rect2(-26, -34, 8, 34), tint.darkened(0.25))
	ci.draw_rect(Rect2(-12, -28, 34, 4), Color(0.95, 0.95, 0.92))
	ci.draw_rect(Rect2(-12, -20, 34, 4), Color(0.95, 0.95, 0.92))
	ci.draw_rect(Rect2(-12, -12, 22, 4), Color(0.95, 0.95, 0.92))


static func draw_icon_pencil(ci: CanvasItem, info: Dictionary) -> void:
	var tint := Color(str(info.get("color", "#FFD54F")))
	_draw_icon_shadow(ci)
	ci.draw_set_transform(Vector2.ZERO, deg_to_rad(-30), Vector2.ONE)
	ci.draw_rect(Rect2(-8, -36, 16, 40), tint)
	ci.draw_rect(Rect2(-8, -36, 16, 8), Color(0.9, 0.4, 0.3))
	ci.draw_rect(Rect2(-2, -44, 4, 8), Color(0.55, 0.4, 0.3))
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func draw_icon_ball(ci: CanvasItem, info: Dictionary) -> void:
	var tint := Color(str(info.get("color", "#FF7043")))
	_draw_icon_shadow(ci)
	ci.draw_circle(Vector2(0, -20), 20.0, tint)
	ci.draw_arc(Vector2(0, -20), 20.0, -0.9, 0.9, 12, Color(0.35, 0.2, 0.15), 2.0)
	ci.draw_arc(Vector2(0, -20), 20.0, PI - 0.9, PI + 0.9, 12, Color(0.35, 0.2, 0.15), 2.0)
	ci.draw_line(Vector2(-20, -20), Vector2(20, -20), Color(0.35, 0.2, 0.15), 2.0)


static func draw_icon_dish(ci: CanvasItem, info: Dictionary) -> void:
	var tint := Color(str(info.get("color", "#FF7043")))
	_draw_icon_shadow(ci)
	ci.draw_circle(Vector2(0, -16), 26.0, Color(0.97, 0.97, 1.0))
	ci.draw_circle(Vector2(0, -16), 20.0, Color(0.9, 0.9, 0.95))
	ci.draw_circle(Vector2(-6, -20), 9.0, Color(0.45, 0.7, 0.35))
	ci.draw_circle(Vector2(8, -18), 8.0, tint)
	ci.draw_circle(Vector2(2, -8), 6.0, Color(0.95, 0.8, 0.4))


static func draw_icon_juice(ci: CanvasItem, info: Dictionary) -> void:
	var tint := Color(str(info.get("color", "#FFB74D")))
	_draw_icon_shadow(ci)
	ci.draw_rect(Rect2(-14, -40, 28, 36), tint)
	ci.draw_rect(Rect2(-16, -44, 32, 6), tint.lightened(0.2))
	ci.draw_line(Vector2(6, -44), Vector2(14, -58), Color(0.9, 0.3, 0.3), 3.0)


static func draw_icon_burger(ci: CanvasItem, info: Dictionary) -> void:
	var tint := Color(str(info.get("color", "#E57373")))
	_draw_icon_shadow(ci)
	# 上层面包
	ci.draw_circle(Vector2(0, -28), 22.0, Color(0.9, 0.72, 0.42))
	ci.draw_rect(Rect2(-22, -30, 44, 10), Color(0.9, 0.72, 0.42))
	# 生菜 + 肉饼
	ci.draw_rect(Rect2(-24, -20, 48, 6), Color(0.45, 0.72, 0.4))
	ci.draw_rect(Rect2(-24, -14, 48, 8), tint)
	# 芝士
	ci.draw_colored_polygon(PackedVector2Array([Vector2(-22, -12), Vector2(22, -12), Vector2(14, -6), Vector2(-14, -6)]), Color(1.0, 0.85, 0.4))
	# 下层面包
	ci.draw_rect(Rect2(-22, -6, 44, 10), Color(0.9, 0.72, 0.42))
	ci.draw_circle(Vector2(0, 4), 22.0, Color(0.9, 0.72, 0.42))


static func _draw_icon_shadow(ci: CanvasItem) -> void:
	ci.draw_set_transform(Vector2(0, 4), 0.0, Vector2(0.9, 0.45))
	ci.draw_circle(Vector2.ZERO, 30.0, Color(0.15, 0.1, 0.08, 0.15))
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
