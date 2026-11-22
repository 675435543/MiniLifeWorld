extends SceneTree
## 交互验收：注入真实输入事件，验证 M1 的拖拽、双击换动作、头像生成角色。
## 用法：godot --path . --script res://tests/ui_probe.gd （窗口模式；headless 下窗口可能为 0 尺寸）
## 注意：输入事件坐标是「窗口坐标」，需先用根窗口的 final transform 把设计坐标换算过去。


func _initialize() -> void:
	var room: Control = load("res://scenes/home/home.tscn").instantiate()
	root.add_child(room)
	await process_frame
	await process_frame
	var to_window: Transform2D = root.get_final_transform()
	print("UI_PROBE: 根窗口尺寸=", root.size, " final_transform=", to_window)

	var ok := true
	var chars: Node = room.get_node("Characters")
	if chars.get_child_count() != 1:
		push_error("初始角色数量异常: " + str(chars.get_child_count()))
		ok = false
	var c: Node2D = chars.get_child(0)
	var start_pos: Vector2 = c.position

	# 拖拽：按下角色 → 向右拖 200px → 松开
	_press(to_window * c.position)
	await process_frame
	await process_frame
	_move(to_window * (c.position + Vector2(200, 0)))
	await process_frame
	await process_frame
	_release(to_window * (c.position + Vector2(200, 0)))
	await process_frame
	await process_frame
	var moved: Vector2 = c.position
	if absf(moved.x - start_pos.x - 200.0) > 1.0:
		push_error("拖拽位置异常: %s -> %s" % [start_pos, moved])
		ok = false
	else:
		print("UI_PROBE: 拖拽 OK %s -> %s" % [start_pos, moved])

	# 双击：快速点按一次，状态应切换
	var state_before: int = c.state
	_press(to_window * c.position)
	await process_frame
	_release(to_window * c.position)
	await process_frame
	await process_frame
	if c.state == state_before:
		push_error("双击未切换状态")
		ok = false
	else:
		print("UI_PROBE: 双击切换动作 OK %d -> %d" % [state_before, c.state])

	# 头像：点击第一个头像，角色数量 +1
	var bar: Node = room.get_node("AvatarBar")
	var count_before: int = chars.get_child_count()
	var btn: Control = bar.get_child(0)
	var center: Vector2 = btn.get_global_rect().get_center()
	_press(to_window * center)
	await process_frame
	_release(to_window * center)
	await process_frame
	await process_frame
	if chars.get_child_count() != count_before + 1:
		push_error("头像点击未生成角色: %d -> %d" % [count_before, chars.get_child_count()])
		ok = false
	else:
		print("UI_PROBE: 头像生成角色 OK")

	print("UI_PROBE: " + ("PASS" if ok else "FAIL"))
	room.queue_free()
	quit(0 if ok else 1)


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
