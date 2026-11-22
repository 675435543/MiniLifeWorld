class_name Item
extends PropDraw
## 可交互道具/家具（M2）。
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


static func _draw_icon_shadow(ci: CanvasItem) -> void:
	ci.draw_set_transform(Vector2(0, 4), 0.0, Vector2(0.9, 0.45))
	ci.draw_circle(Vector2.ZERO, 30.0, Color(0.15, 0.1, 0.08, 0.15))
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
