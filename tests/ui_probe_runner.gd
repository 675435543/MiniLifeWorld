extends Node
## 场景版交互验收（M1+M2）：真实注入鼠标事件。
## 用场景启动避免 --script 模式在主循环脚本编译时的 autoload 时序问题。
## 运行：godot --path . res://tests/ui_probe.tscn （窗口模式）

const ST_IDLE := 0
const ST_SIT := 2
const ST_SLEEP := 3
const ST_EAT := 4
const ST_HAPPY := 5
const ST_INTERACT := 6

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

	# ---- M5：存档恢复（退出场景 → 重新进入应恢复位置/服装）----
	var saved_shirt: Color = c.shirt_color()
	var saved_x: float = c.position.x
	room.queue_free()
	await _frames(3)
	var room2: Control = load("res://scenes/home/home.tscn").instantiate()
	add_child(room2)
	await _frames(3)
	var chars2: Node = room2.get_node("Characters")
	if chars2.get_child_count() < 1:
		_fail("存档恢复后角色缺失")
	else:
		var c2: Node2D = chars2.get_child(0)
		var pos_ok := absf(c2.position.x - saved_x) <= 1.5
		var shirt_ok: bool = c2.shirt_color().to_html(false) == saved_shirt.to_html(false)
		if pos_ok and shirt_ok:
			print("UI_PROBE: 存档恢复 OK")
		else:
			_fail("存档恢复不符 pos=%f/%f shirt=%s/%s" % [c2.position.x, saved_x, c2.shirt_color().to_html(false), saved_shirt.to_html(false)])
	room2.queue_free()
	await _frames(2)

	# ---- M3：医院场景 ----
	var hospital: Control = load("res://scenes/hospital/hospital.tscn").instantiate()
	add_child(hospital)
	await _frames(2)
	var hchars: Node = hospital.get_node("Characters")
	var hc: Node2D = hchars.get_child(0)
	var hbed: Node2D = hospital.get_node("Items/HospitalBed")
	var hbed_center: Vector2 = hbed.zone_rect().get_center()
	_press(to_window * hc.position)
	await _frames(2)
	_move(to_window * hbed_center)
	await _frames(2)
	_release(to_window * hbed_center)
	await _frames(2)
	if hc.state != ST_SLEEP:
		_fail("医院诊疗床未躺下 state=" + str(hc.state))
	else:
		print("UI_PROBE: 医院诊疗床 OK")

	var hbar: Node = hospital.get_node("ItemBar")
	var steth_btn: Control = hbar.get_child(0)
	_press(to_window * steth_btn.get_global_rect().get_center())
	await _frames(2)
	_move(to_window * (hc.position + Vector2(0, -10)))
	await _frames(2)
	_release(to_window * (hc.position + Vector2(0, -10)))
	await _frames(2)
	if hc.state != ST_INTERACT:
		_fail("听诊器未触发检查 state=" + str(hc.state))
	else:
		print("UI_PROBE: 听诊器检查 OK")

	var med_btn: Control = hbar.get_child(1)
	_press(to_window * med_btn.get_global_rect().get_center())
	await _frames(2)
	_move(to_window * (hc.position + Vector2(0, -10)))
	await _frames(2)
	_release(to_window * (hc.position + Vector2(0, -10)))
	await _frames(2)
	if hc.state != ST_EAT:
		_fail("药瓶未触发吃药 state=" + str(hc.state))
	else:
		print("UI_PROBE: 吃药 OK")

	# ---- M4：学校场景 ----
	hospital.queue_free()
	await _frames(2)
	var school: Control = load("res://scenes/school/school.tscn").instantiate()
	add_child(school)
	await _frames(2)
	var schars: Node = school.get_node("Characters")
	var sc: Node2D = schars.get_child(0)
	var desk1: Node2D = school.get_node("Items/Desk1")
	var desk1_center: Vector2 = desk1.zone_rect().get_center()
	_press(to_window * sc.position)
	await _frames(2)
	_move(to_window * desk1_center)
	await _frames(2)
	_release(to_window * desk1_center)
	await _frames(2)
	if sc.state != ST_SIT:
		_fail("课桌未坐下 state=" + str(sc.state))
	else:
		print("UI_PROBE: 课桌坐下 OK")

	var sbar: Node = school.get_node("ItemBar")
	var book_btn: Control = sbar.get_child(0)
	_press(to_window * book_btn.get_global_rect().get_center())
	await _frames(2)
	_move(to_window * (sc.position + Vector2(0, -10)))
	await _frames(2)
	_release(to_window * (sc.position + Vector2(0, -10)))
	await _frames(2)
	if sc.state != ST_INTERACT:
		_fail("书本未触发阅读 state=" + str(sc.state))
	else:
		print("UI_PROBE: 读书 OK")

	var ball_btn: Control = sbar.get_child(2)
	_press(to_window * ball_btn.get_global_rect().get_center())
	await _frames(2)
	_move(to_window * (sc.position + Vector2(0, -10)))
	await _frames(2)
	_release(to_window * (sc.position + Vector2(0, -10)))
	await _frames(2)
	if sc.state != ST_HAPPY:
		_fail("篮球未触发玩耍 state=" + str(sc.state))
	else:
		print("UI_PROBE: 玩球 OK")

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
