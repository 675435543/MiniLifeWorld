extends Node
## 导航验收（真实鼠标注入）：菜单 → 世界地图 → 各场景 → 返回，确认所有场景能进得去。
## 运行：godot --path . res://tests/nav_probe.tscn

var _ok := true


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	await get_tree().process_frame
	var menu: Control = load("res://scenes/main/main_menu.tscn").instantiate()
	get_tree().root.add_child(menu)
	get_tree().current_scene = menu
	await _frames(3)
	var start_btn := menu.get_node("Center/VBox/StartButton") as Button
	_click(start_btn)
	await _frames(90)
	var cur := get_tree().current_scene
	print("NAV: 当前场景=", cur.name if cur else "null")
	if cur == null or cur.name != "WorldMap":
		_fail("点击开始游戏后未进入世界地图")
	else:
		print("NAV: 进入世界地图 OK")

	for pair in [["HomeBtn", "Home"], ["HospitalBtn", "Hospital"], ["SchoolBtn", "School"], ["PlaygroundBtn", "Playground"], ["RestaurantBtn", "Restaurant"], ["AirportBtn", "Airport"]]:
		var map := get_tree().current_scene
		var btn := map.get_node_or_null("Center/HBox/" + str(pair[0])) as Button
		if btn == null:
			_fail("地图缺少按钮: " + str(pair[0]))
			continue
		_click(btn)
		await _frames(90)
		var c := get_tree().current_scene
		var expect: String = str(pair[1])
		if c == null or c.name != expect:
			_fail("未能进入 %s（当前=%s）" % [expect, c.name if c else "null"])
			break
		print("NAV: 进入 %s OK" % expect)
		var back := c.get_node_or_null("BackButton") as Button
		if back == null:
			_fail("%s 缺少返回按钮" % expect)
			break
		_click(back)
		await _frames(90)
		var m := get_tree().current_scene
		if m == null or m.name != "WorldMap":
			_fail("未能返回地图（当前=%s）" % (m.name if m else "null"))
			break

	print("NAV_PROBE: " + ("PASS" if _ok else "FAIL"))
	get_tree().quit(0 if _ok else 1)


func _click(btn: Button) -> void:
	var to_window: Transform2D = get_viewport().get_final_transform()
	var pos: Vector2 = to_window * btn.get_global_rect().get_center()
	_press(pos)
	await get_tree().process_frame
	_release(pos)


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
