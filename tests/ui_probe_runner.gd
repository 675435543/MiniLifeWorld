extends Node
## 场景版交互验收（M1+M2）：真实注入鼠标事件。
## 用场景启动避免 --script 模式在主循环脚本编译时的 autoload 时序问题。
## 运行：godot --path . res://tests/ui_probe.tscn （窗口模式）

const ST_IDLE := 0
const ST_SIT := 2
const ST_SLEEP := 3
const ST_EAT := 4
const ST_HAPPY := 5

var _ok := true


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	await get_tree().process_frame
	var room: Control = load("res://scenes/home/home.tscn").instantiate()
	add_child(room)
	await get_tree().process_frame
	await get_tree().process_frame
	var to_window: Transform2D = get_viewport().get_final_transform()
	print("UI_PROBE: 根窗口尺寸=", get_viewport().get_visible_rect().size)

	var chars: Node = room.get_node("Characters")
	if chars.get_child_count() != 1:
		_fail("初始角色数量异常: " + str(chars.get_child_count()))
	var c: Node2D = chars.get_child(0)
	var start_pos: Vector2 = c.position

	# ---- M1：拖拽 ----
	_press(to_window * c.position)
	await _frames(2)
	_move(to_window * (c.position + Vector2(200, 0)))
	await _frames(2)
	_release(to_window * (c.position + Vector2(200, 0)))
	await _frames(2)
	if c.position.distance_to(start_pos) < 100.0:
		_fail("拖拽位移不足: %s -> %s" % [start_pos, c.position])
	else:
		print("UI_PROBE: 拖拽 OK")

	# ---- M1：双击换动作 ----
	var state_before: int = c.state
	_press(to_window * c.position)
	await get_tree().process_frame
	_release(to_window * c.position)
	await _frames(2)
	if c.state == state_before:
		_fail("双击未切换状态")
	else:
		print("UI_PROBE: 双击切换动作 OK")

	# ---- 头像生成角色 ----
	var count_before: int = chars.get_child_count()
	var avatar_btn: Control = room.get_node("AvatarBar").get_child(0)
	_press(to_window * avatar_btn.get_global_rect().get_center())
	await get_tree().process_frame
	_release(to_window * avatar_btn.get_global_rect().get_center())
	await _frames(2)
	if chars.get_child_count() != count_before + 1:
		_fail("头像点击未生成角色")
	else:
		print("UI_PROBE: 头像生成角色 OK")

	# ---- M2：拖角色上床 → 躺下 ----
	var bed: Node2D = room.get_node("Items/Bed")
	var bed_center: Vector2 = bed.zone_rect().get_center()
	_press(to_window * c.position)
	await get_tree().process_frame
	_move(to_window * bed_center)
	await get_tree().process_frame
	_move(to_window * bed_center)
	await _frames(2)
	_release(to_window * bed_center)
	await _frames(2)
	if c.state != ST_SLEEP:
		_fail("上床未躺下 state=" + str(c.state))
	else:
		print("UI_PROBE: 上床躺下 OK")

	# ---- M2：拖角色到沙发 → 坐下 ----
	var sofa: Node2D = room.get_node("Items/Sofa")
	var sofa_center: Vector2 = sofa.zone_rect().get_center()
	_press(to_window * c.position)
	await get_tree().process_frame
	_move(to_window * sofa_center)
	await _frames(2)
	_release(to_window * sofa_center)
	await _frames(2)
	if c.state != ST_SIT:
		_fail("上沙发未坐下 state=" + str(c.state))
	else:
		print("UI_PROBE: 坐下 OK")

	# ---- M2：食物拖到角色身上 → 吃 ----
	var item_bar: Node = room.get_node("ItemBar")
	var food_btn: Control = item_bar.get_child(0)
	var food_center: Vector2 = food_btn.get_global_rect().get_center()
	_press(to_window * food_center)
	await _frames(2)
	_move(to_window * (c.position + Vector2(0, -10)))
	await _frames(2)
	_release(to_window * (c.position + Vector2(0, -10)))
	await _frames(2)
	if c.state != ST_EAT:
		_fail("食物交互未吃 state=" + str(c.state))
	else:
		print("UI_PROBE: 吃东西 OK")

	# ---- M2：衣服拖到角色身上 → 换装 ----
	var clothes_btn: Control = item_bar.get_child(2)
	_press(to_window * clothes_btn.get_global_rect().get_center())
	await _frames(2)
	_move(to_window * (c.position + Vector2(0, -10)))
	await _frames(2)
	_release(to_window * (c.position + Vector2(0, -10)))
	await _frames(2)
	if c.state != ST_HAPPY:
		_fail("换装未触发 state=" + str(c.state))
	else:
		print("UI_PROBE: 换装 OK")

	print("UI_PROBE: " + ("PASS" if _ok else "FAIL"))
	get_tree().quit(0 if _ok else 1)


func _fail(msg: String) -> void:
	push_error(msg)
	_ok = false


func _frames(n: int) -> void:
	for i in range(n):
		await get_tree().process_frame


func _press(pos: Vector2) -> void:
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	ev.position = pos
	Input.parse_input_event(ev)


func _release(pos: Vector2) -> void:
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = false
	ev.position = pos
	Input.parse_input_event(ev)


func _move(pos: Vector2) -> void:
	var ev := InputEventMouseMotion.new()
	ev.position = pos
	ev.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(ev)
