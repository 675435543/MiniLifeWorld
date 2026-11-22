class_name PropDraw
extends Node2D
## 占位家具/杂物（程序化矢量绘制）。
## M2 起会被可交互的 Item 替换，这里先保证场景「有东西可看」。

@export var prop_type := ""


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	_draw_shadow()
	match prop_type:
		"sofa":
			_sofa()
		"table":
			_table()
		"tv":
			_tv()
		"fridge":
			_fridge()
		"bed":
			_bed()
		"plant":
			_plant()
		"desk":
			_desk()
		"school_desk":
			_school_desk()
		"chairs":
			_chairs()
		"hospital_bed":
			_hospital_bed()
		"cabinet":
			_cabinet()
		"blackboard":
			_blackboard()
		"hoop":
			_hoop()


func _draw_shadow() -> void:
	draw_set_transform(Vector2(0, 6), 0.0, Vector2(1.6, 0.5))
	draw_circle(Vector2.ZERO, 46.0, Color(0.15, 0.1, 0.08, 0.14))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _sofa() -> void:
	var c := Color(0.62, 0.45, 0.40)
	var light := c.lightened(0.18)
	draw_rect(Rect2(-130, -92, 260, 92), c)
	draw_rect(Rect2(-130, -40, 260, 44), light)
	draw_rect(Rect2(-146, -52, 22, 52), c.darkened(0.2))
	draw_rect(Rect2(124, -52, 22, 52), c.darkened(0.2))
	draw_rect(Rect2(-104, -82, 62, 42), light)
	draw_rect(Rect2(-28, -82, 62, 42), light)
	draw_rect(Rect2(48, -82, 62, 42), light)


func _table() -> void:
	var wood := Color(0.72, 0.54, 0.38)
	draw_rect(Rect2(-100, -66, 200, 22), wood)
	draw_rect(Rect2(-84, -44, 16, 44), wood.darkened(0.15))
	draw_rect(Rect2(68, -44, 16, 44), wood.darkened(0.15))
	draw_rect(Rect2(-20, -92, 18, 26), Color(0.55, 0.73, 0.85))
	draw_rect(Rect2(28, -86, 26, 20), Color(0.95, 0.78, 0.35))


func _tv() -> void:
	draw_rect(Rect2(-96, -170, 192, 112), Color(0.22, 0.24, 0.28))
	draw_rect(Rect2(-84, -158, 168, 88), Color(0.35, 0.55, 0.75))
	draw_rect(Rect2(-40, -58, 80, 12), Color(0.4, 0.42, 0.45))
	draw_rect(Rect2(-70, -46, 140, 10), Color(0.45, 0.47, 0.5))


func _fridge() -> void:
	var body := Color(0.93, 0.94, 0.97)
	draw_rect(Rect2(-46, -200, 92, 200), body)
	draw_line(Vector2(-46, -126), Vector2(46, -126), Color(0.6, 0.63, 0.68), 3.0)
	draw_rect(Rect2(-10, -186, 10, 44), Color(0.55, 0.58, 0.62))
	draw_rect(Rect2(-10, -108, 10, 52), Color(0.55, 0.58, 0.62))


func _bed() -> void:
	var frame := Color(0.55, 0.40, 0.30)
	draw_rect(Rect2(-150, -46, 300, 46), frame)
	draw_rect(Rect2(-150, -74, 300, 32), Color(0.96, 0.96, 0.98))
	draw_rect(Rect2(-126, -68, 64, 26), Color(0.99, 0.99, 1.0))
	draw_rect(Rect2(-52, -70, 196, 30), Color(0.85, 0.78, 0.95))
	draw_rect(Rect2(-150, -28, 300, 8), frame.darkened(0.2))


func _plant() -> void:
	draw_rect(Rect2(-30, -34, 60, 34), Color(0.75, 0.5, 0.35))
	draw_rect(Rect2(-20, -34, 40, 10), Color(0.6, 0.38, 0.26))
	draw_circle(Vector2(0, -66), 26.0, Color(0.36, 0.6, 0.32))
	draw_circle(Vector2(-18, -50), 18.0, Color(0.42, 0.68, 0.36))
	draw_circle(Vector2(18, -50), 18.0, Color(0.42, 0.68, 0.36))


func _desk() -> void:
	var wood := Color(0.85, 0.85, 0.9)
	draw_rect(Rect2(-130, -96, 260, 24), wood)
	draw_rect(Rect2(-130, -72, 260, 72), wood.darkened(0.13))
	draw_rect(Rect2(-60, -170, 120, 74), Color(0.25, 0.27, 0.3))
	draw_rect(Rect2(-52, -162, 104, 58), Color(0.42, 0.65, 0.85))
	draw_rect(Rect2(50, -110, 40, 30), Color(0.95, 0.9, 0.6))


func _school_desk() -> void:
	var wood := Color(0.82, 0.78, 0.72)
	draw_rect(Rect2(-80, -64, 160, 18), wood)
	draw_rect(Rect2(-70, -46, 12, 46), wood.darkened(0.18))
	draw_rect(Rect2(58, -46, 12, 46), wood.darkened(0.18))
	draw_rect(Rect2(-20, -84, 40, 20), Color(0.9, 0.85, 0.7))


func _chairs() -> void:
	_chair(-90)
	_chair(0)
	_chair(90)


func _chair(x: float) -> void:
	var blue := Color(0.45, 0.65, 0.85)
	draw_rect(Rect2(x - 22, -56, 44, 10), blue)
	draw_rect(Rect2(x - 22, -90, 44, 40), blue.darkened(0.1))
	draw_rect(Rect2(x - 20, -46, 8, 46), Color(0.3, 0.3, 0.32))
	draw_rect(Rect2(x + 12, -46, 8, 46), Color(0.3, 0.3, 0.32))


func _hospital_bed() -> void:
	var white := Color(0.97, 0.98, 1.0)
	draw_rect(Rect2(-150, -54, 300, 54), Color(0.8, 0.85, 0.92))
	draw_rect(Rect2(-150, -86, 300, 34), white)
	draw_rect(Rect2(-132, -80, 60, 24), white)
	draw_circle(Vector2(-120, -6), 12.0, Color(0.35, 0.37, 0.4))
	draw_circle(Vector2(120, -6), 12.0, Color(0.35, 0.37, 0.4))
	var frame := Color(0.55, 0.65, 0.75)
	draw_rect(Rect2(-162, -120, 20, 120), frame)
	var red := Color(0.85, 0.3, 0.3)
	draw_rect(Rect2(-156, -108, 8, 24), red)
	draw_rect(Rect2(-168, -100, 32, 8), red)


func _cabinet() -> void:
	draw_rect(Rect2(-90, -180, 180, 180), Color(0.9, 0.92, 0.95))
	for i in range(3):
		draw_line(Vector2(-90, -180 + 60 * (i + 1)), Vector2(90, -180 + 60 * (i + 1)), Color(0.65, 0.7, 0.75), 3.0)
	var bottle_colors := [Color(0.85, 0.4, 0.35), Color(0.4, 0.7, 0.5), Color(0.9, 0.75, 0.3), Color(0.55, 0.6, 0.9)]
	for i in range(4):
		draw_circle(Vector2(-60 + i * 40, -150 + (i % 3) * 20), 9.0, bottle_colors[i % 4])


func _blackboard() -> void:
	draw_rect(Rect2(-160, -170, 320, 134), Color(0.55, 0.4, 0.28))
	draw_rect(Rect2(-148, -158, 296, 110), Color(0.25, 0.38, 0.3))
	var chalk := Color(0.92, 0.92, 0.88)
	draw_line(Vector2(-120, -130), Vector2(-70, -130), chalk, 4.0)
	draw_line(Vector2(-120, -112), Vector2(-90, -112), chalk, 4.0)
	draw_line(Vector2(-30, -130), Vector2(10, -112), chalk, 4.0)
	draw_rect(Rect2(-120, -40, 60, 12), Color(0.6, 0.45, 0.3))


func _hoop() -> void:
	draw_rect(Rect2(-6, -260, 12, 260), Color(0.55, 0.57, 0.62))
	draw_rect(Rect2(-60, -250, 120, 70), Color(0.97, 0.97, 1.0))
	draw_rect(Rect2(-14, -200, 28, 26), Color(0.95, 0.6, 0.3), false, 3.0)
	draw_arc(Vector2(0, -178), 30.0, 0.0, TAU, 16, Color(0.85, 0.45, 0.25), 5.0)
	for i in range(5):
		draw_line(Vector2(-24 + i * 12, -170), Vector2(-6 + i * 3, -150), Color(0.9, 0.9, 0.92), 1.5)
