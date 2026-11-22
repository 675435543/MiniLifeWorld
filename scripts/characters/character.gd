class_name Character
extends Node2D
## 可拖拽角色（M1）：程序化绘制外观 + 状态动作。
## 状态：idle 呼吸 / walk 摇摆 / sit 坐 / sleep 躺 / eat 吃 / happy 跳 / interact。
## 后续里程碑接入家具交互与存档恢复。

enum State { IDLE, WALK, SIT, SLEEP, EAT, HAPPY, INTERACT }

const STATE_CYCLE := [State.IDLE, State.HAPPY, State.EAT, State.SIT, State.SLEEP]

@export var char_id := ""

var state := State.IDLE
var palette: Dictionary = {}
var display_name := ""

var _t := 0.0
var _drag_scale := 1.0
var _blink_timer := 0.0
var _blink_left := 0.0
var _hop := 0.0


func _ready() -> void:
	var info: Dictionary = GameData.characters.get(char_id, {})
	display_name = str(info.get("name", char_id))
	palette = info.get("palette", {})
	_blink_timer = randf_range(2.0, 4.0)
	queue_redraw()


func set_state(next: State) -> void:
	if state == next:
		return
	state = next
	_hop = 0.0
	rotation = PI * 0.5 if state == State.SLEEP else 0.0
	queue_redraw()


func begin_drag() -> void:
	_drag_scale = 1.12


func end_drag() -> void:
	_drag_scale = 1.0


func _process(delta: float) -> void:
	_t += delta
	var animated := Vector2.ONE
	match state:
		State.IDLE:
			animated = Vector2(1.0, 1.0 + sin(_t * 2.4) * 0.015)
		State.WALK:
			animated = Vector2(1.0 + sin(_t * 10.0) * 0.03, 1.0)
		State.HAPPY:
			_hop = absf(sin(_t * 8.0)) * -16.0
			animated = Vector2(1.0 - absf(_hop) * 0.006, 1.0 + absf(_hop) * 0.003)
			queue_redraw()
		State.EAT:
			animated = Vector2(1.0, 1.0 + sin(_t * 6.0) * 0.03)
		State.SLEEP:
			animated = Vector2(1.0, 1.0 + sin(_t * 1.5) * 0.01)
		State.SIT:
			animated = Vector2.ONE
		State.INTERACT:
			animated = Vector2.ONE
	scale = animated * _drag_scale

	# 随机眨眼
	_blink_timer -= delta
	if _blink_timer <= 0.0:
		_blink_left = 0.12
		_blink_timer = randf_range(2.5, 4.5)
	if _blink_left > 0.0:
		_blink_left -= delta
		queue_redraw()


func _draw() -> void:
	var skin := Color(str(palette.get("skin", "#FFCC9C")))
	var hair := Color(str(palette.get("hair", "#5D4037")))
	var shirt := Color(str(palette.get("shirt", "#FF8A65")))
	var pants := Color(str(palette.get("pants", "#64B5F6")))
	var ink := Color(0.2, 0.13, 0.10)

	# 地面阴影（不随跳跃移动）
	draw_set_transform(Vector2(0, _hop), 0.0, Vector2.ONE)
	draw_set_transform(Vector2(0, 2), 0.0, Vector2(1.5, 0.55))
	draw_circle(Vector2.ZERO, 20.0, Color(0.15, 0.1, 0.08, 0.18))
	draw_set_transform(Vector2(0, _hop), 0.0, Vector2.ONE)

	var sit := state == State.SIT
	if sit:
		draw_rect(Rect2(-30, -20, 30, 14), pants)
		draw_rect(Rect2(0, -20, 30, 14), pants)
	else:
		draw_rect(Rect2(-17, -36, 14, 36), pants)
		draw_rect(Rect2(3, -36, 14, 36), pants)

	var torso_y := -66.0 if sit else -80.0
	draw_rect(Rect2(-24, torso_y, 48, 50), shirt)
	draw_line(Vector2(-24, torso_y + 12), Vector2(-36, torso_y + 40), skin, 9.0)
	draw_line(Vector2(24, torso_y + 12), Vector2(36, torso_y + 40), skin, 9.0)

	var head_y := torso_y - 26.0
	draw_circle(Vector2(0, head_y - 6), 29.0, hair)
	draw_circle(Vector2(0, head_y), 26.0, skin)

	var eye_y := head_y - 2.0
	if _blink_left > 0.0:
		draw_line(Vector2(-12, eye_y), Vector2(-6, eye_y), ink, 2.0)
		draw_line(Vector2(6, eye_y), Vector2(12, eye_y), ink, 2.0)
	else:
		draw_circle(Vector2(-9, eye_y), 3.4, ink)
		draw_circle(Vector2(9, eye_y), 3.4, ink)

	if state == State.EAT:
		draw_circle(Vector2(0, head_y + 12), 5.0, ink)
	else:
		draw_arc(Vector2(0, head_y + 6), 8.0, deg_to_rad(20), deg_to_rad(160), 12, ink, 2.0)

	var blush := Color(1.0, 0.55, 0.5, 0.35)
	draw_circle(Vector2(-16, head_y + 6), 4.0, blush)
	draw_circle(Vector2(16, head_y + 6), 4.0, blush)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
