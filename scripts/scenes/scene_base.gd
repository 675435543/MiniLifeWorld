extends Control
## 场景基类（M1）：角色栏 + 触摸/鼠标拖拽角色 + 双击切换动作。
## 后续里程碑在此基础加入家具交互与存档恢复。

const CHARACTER_SCENE := preload("res://scenes/characters/character.tscn")
const ROOM_RECT := Rect2(80.0, 320.0, 1760.0, 540.0)

@export var scene_id := ""

var _dragging: Character = null
var _drag_offset := Vector2.ZERO
var _press_pos := Vector2.ZERO
var _press_time := 0


func _ready() -> void:
	var info: Dictionary = GameData.scenes.get(scene_id, {})
	var title_label := get_node_or_null("TitleLabel") as Label
	if title_label:
		title_label.text = str(info.get("name", "场景"))
	var back_btn := get_node_or_null("BackButton") as Button
	if back_btn:
		back_btn.pressed.connect(_on_back)
	_build_avatar_bar()
	var chars := get_node_or_null("Characters")
	if chars and chars.get_child_count() == 0:
		spawn_character("mom")


func _process(_delta: float) -> void:
	# 兜底：拖拽中若鼠标已松开（比如在按钮上松手），强制放下，避免角色卡住
	if _dragging and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_release_at(get_global_mouse_position())


func _build_avatar_bar() -> void:
	var bar := HBoxContainer.new()
	bar.name = "AvatarBar"
	bar.add_theme_constant_override("separation", 14)
	# PASS：不拦截拖拽事件，避免角色在栏下方时点不到
	bar.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(bar)
	bar.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	bar.grow_horizontal = Control.GROW_DIRECTION_END
	bar.offset_left = 28.0
	bar.offset_right = 28.0
	bar.offset_top = -206.0
	bar.offset_bottom = -28.0
	for id in GameData.characters:
		var avatar := AvatarButton.new()
		avatar.char_id = str(id)
		avatar.pressed.connect(_on_avatar_pressed.bind(str(id)))
		bar.add_child(avatar)


func spawn_character(char_id: String) -> Character:
	var c := CHARACTER_SCENE.instantiate() as Character
	c.char_id = char_id
	var chars := get_node("Characters")
	chars.add_child(c)
	c.position = Vector2(randf_range(560.0, 820.0), randf_range(720.0, 830.0))
	c.set_state(Character.State.IDLE)
	return c


func _on_avatar_pressed(char_id: String) -> void:
	spawn_character(char_id)


func _on_back() -> void:
	SceneManager.go_to_map()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var pos := _to_room_pos(event.position)
		if event.pressed:
			_press_at(pos)
		else:
			_release_at(pos)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
		if _dragging:
			var pos := _to_room_pos(event.position)
			_dragging.position = _clamp_room(pos + _drag_offset)
			get_viewport().set_input_as_handled()


func _to_room_pos(screen_pos: Vector2) -> Vector2:
	return get_global_transform_with_canvas().affine_inverse() * screen_pos


func _clamp_room(pos: Vector2) -> Vector2:
	return Vector2(
		clampf(pos.x, ROOM_RECT.position.x, ROOM_RECT.position.x + ROOM_RECT.size.x),
		clampf(pos.y, ROOM_RECT.position.y, ROOM_RECT.position.y + ROOM_RECT.size.y)
	)


func _press_at(pos: Vector2) -> void:
	if _dragging:
		_release_at(_dragging.position)
	var chars := get_node("Characters").get_children()
	for i in range(chars.size() - 1, -1, -1):
		var c := chars[i] as Character
		if c == null:
			continue
		if Rect2(c.position + Vector2(-46, -152), Vector2(92, 160)).has_point(pos):
			_dragging = c
			_drag_offset = c.position - pos
			_press_pos = pos
			_press_time = Time.get_ticks_msec()
			c.begin_drag()
			return


func _release_at(pos: Vector2) -> void:
	if _dragging == null:
		return
	var c := _dragging
	_dragging = null
	c.end_drag()
	var moved := pos.distance_to(_press_pos) > 12.0
	var quick := Time.get_ticks_msec() - _press_time < 380
	if not moved and quick:
		_cycle_state(c)


func _cycle_state(c: Character) -> void:
	var idx: int = Character.STATE_CYCLE.find(c.state)
	c.set_state(Character.STATE_CYCLE[(idx + 1) % Character.STATE_CYCLE.size()])
