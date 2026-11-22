class_name Airplane
extends Node2D
## 飞机（机场场景）：点击在左右两端之间飞行；小人可拖上飞机一起飞。


var passenger: Node2D = null
var _flying := false
var _facing_left := false
var _parked_y := 0.0


func _ready() -> void:
	_parked_y = position.y


func hit_rect() -> Rect2:
	return Rect2(position + Vector2(-240, -100), Vector2(480, 130))


## 小人登机：挂到飞机上，跟着飞机走
func board(c: Character) -> void:
	if passenger != null:
		return
	passenger = c
	c.reparent(self)
	c.position = Vector2(0, 28)
	c.rotation = 0.0


## 把乘客放下来（放回场景）
func unboard() -> Node2D:
	var c := passenger
	if c == null:
		return null
	passenger = null
	var chars := get_parent().get_node("Characters")
	c.reparent(chars)
	c.position = position + Vector2(0, 60)
	return c


## 点击飞机：左→右 或 右→左
func click() -> void:
	if _flying:
		return
	_flying = true
	var fly_right := position.x < 960.0
	_facing_left = not fly_right
	queue_redraw()
	var target_x := 1660.0 if fly_right else 260.0
	var tw := create_tween()
	tw.tween_property(self, "position:x", target_x, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.finished.connect(func() -> void: _flying = false)
	var arc := create_tween()
	arc.tween_property(self, "position:y", _parked_y - 130.0, 0.8).set_trans(Tween.TRANS_SINE)
	arc.tween_property(self, "position:y", _parked_y, 0.8).set_trans(Tween.TRANS_SINE)


func _draw() -> void:
	if _facing_left:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(-1.0, 1.0))
	var body := Color(0.86, 0.88, 0.93)
	var body_dark := body.darkened(0.08)
	var blue := Color(0.35, 0.55, 0.85)
	# 尾翼
	draw_colored_polygon(PackedVector2Array([Vector2(-120, -18), Vector2(-182, -62), Vector2(-150, -10)]), blue)
	# 机身
	draw_colored_polygon(PackedVector2Array([Vector2(-140, 0), Vector2(160, 0), Vector2(200, -10), Vector2(160, -20), Vector2(-140, -26), Vector2(-160, -13)]), body)
	draw_circle(Vector2(160, -10), 18.0, body)
	# 机翼
	draw_colored_polygon(PackedVector2Array([Vector2(20, -12), Vector2(-30, -70), Vector2(40, -60), Vector2(90, -12)]), body_dark)
	draw_colored_polygon(PackedVector2Array([Vector2(20, -12), Vector2(-30, 40), Vector2(40, 34), Vector2(90, -12)]), body_dark)
	# 舷窗
	for i in range(6):
		draw_circle(Vector2(-90 + i * 34, -16), 5.0, Color(0.35, 0.6, 0.9))
	# 驾驶舱
	draw_circle(Vector2(140, -16), 6.0, Color(0.35, 0.6, 0.9))
	# 底部起落架小轮
	draw_circle(Vector2(-60, 4), 7.0, Color(0.3, 0.3, 0.33))
	draw_circle(Vector2(60, 4), 7.0, Color(0.3, 0.3, 0.33))
	if _facing_left:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
