extends Control
## 场景基类（M2）：角色栏 + 道具栏 + 拖拽角色/道具 + 家具互动。

const CHARACTER_SCENE := preload("res://scenes/characters/character.tscn")
const ROOM_RECT := Rect2(80.0, 320.0, 1760.0, 540.0)
const ITEM_BAR := ["food", "water_cup", "clothes"]

enum DragKind { NONE, CHARACTER, ITEM }

@export var scene_id := ""

var _dragging: Node2D = null
var _drag_kind := DragKind.NONE
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
	_build_item_bar()
	_restore_or_spawn(info)


func _exit_tree() -> void:
	_save_scene_state()


func _restore_or_spawn(info: Dictionary) -> void:
	var chars := get_node("Characters")
	var saved: Dictionary = SaveManager.scene_state(scene_id)
	var list: Array = saved.get("characters", [])
	if not list.is_empty():
		for entry in list:
			if typeof(entry) != TYPE_DICTIONARY:
				continue
			var e: Dictionary = entry
			var c := CHARACTER_SCENE.instantiate() as Character
			c.char_id = str(e.get("id", ""))
			chars.add_child(c)
			var p: Array = e.get("pos", [0.0, 0.0])
			c.position = Vector2(float(p[0]), float(p[1]))
			var outfit := str(e.get("outfit", ""))
			if not outfit.is_empty():
				c.apply_outfit(Color("#" + outfit))
		return
	spawn_character(str(info.get("default_character", "mom")))


func _save_scene_state() -> void:
	var chars := get_node_or_null("Characters")
	if chars == null:
		return
	var list := []
	for child in chars.get_children():
		var ch := child as Character
		if ch == null:
			continue
		list.append({
			"id": ch.char_id,
			"pos": [ch.position.x, ch.position.y],
			"outfit": ch.shirt_color().to_html(false),
		})
	SaveManager.set_scene_state(scene_id, {"characters": list})
	SaveManager.save_game()


func _process(_delta: float) -> void:
	pass


func _build_avatar_bar() -> void:
	var bar := HBoxContainer.new()
	bar.name = "AvatarBar"
	bar.add_theme_constant_override("separation", 14)
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


func _build_item_bar() -> void:
	var info: Dictionary = GameData.scenes.get(scene_id, {})
	var bar_items: Array = info.get("bar_items", ITEM_BAR)
	var bar := HBoxContainer.new()
	bar.name = "ItemBar"
	bar.add_theme_constant_override("separation", 14)
	bar.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(bar)
	bar.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	bar.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	bar.offset_left = -416.0
	bar.offset_right = -28.0
	bar.offset_top = -206.0
	bar.offset_bottom = -28.0
	for id in bar_items:
		var btn := ItemButton.new()
		btn.item_id = str(id)
		btn.button_down.connect(_on_item_button_down.bind(str(id)))
		bar.add_child(btn)


func spawn_character(char_id: String) -> Character:
	var c := CHARACTER_SCENE.instantiate() as Character
	c.char_id = char_id
	var chars := get_node("Characters")
	chars.add_child(c)
	c.position = Vector2(randf_range(560.0, 820.0), randf_range(720.0, 830.0))
	c.set_state(Character.State.IDLE)
	return c


## 从道具栏按下：立即生成一个跟随指针的可拖道具
func spawn_item_from_bar(item_id: String) -> void:
	if _dragging != null:
		_release_at(_dragging.position)
	var item := Item.new()
	item.item_id = item_id
	_item_parent().add_child(item)
	item.position = get_viewport().get_mouse_position()
	_dragging = item
	_drag_kind = DragKind.ITEM
	item.begin_drag()


func _item_parent() -> Node:
	var items := get_node_or_null("Items")
	return items if items else self


func _on_avatar_pressed(char_id: String) -> void:
	spawn_character(char_id)


func _on_item_button_down(item_id: String) -> void:
	spawn_item_from_bar(item_id)


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
			_move_at(pos)
			get_viewport().set_input_as_handled()


## 兜底监听：即使松手发生在按钮等 UI 上（事件被 GUI 吃掉），也能可靠结束拖拽
func _input(event: InputEvent) -> void:
	if _dragging == null:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_release_at(_to_room_pos(event.position))


func _to_room_pos(screen_pos: Vector2) -> Vector2:
	return get_global_transform_with_canvas().affine_inverse() * screen_pos


func _clamp_room(pos: Vector2) -> Vector2:
	return Vector2(
		clampf(pos.x, ROOM_RECT.position.x, ROOM_RECT.position.x + ROOM_RECT.size.x),
		clampf(pos.y, ROOM_RECT.position.y, ROOM_RECT.position.y + ROOM_RECT.size.y)
	)


func _char_hit(c: Character, pos: Vector2) -> bool:
	return Rect2(c.position + Vector2(-46, -152), Vector2(92, 160)).has_point(pos)


func _character_at(pos: Vector2) -> Character:
	var chars := get_node("Characters").get_children()
	for i in range(chars.size() - 1, -1, -1):
		var c := chars[i] as Character
		if c and _char_hit(c, pos):
			return c
	return null


func _furniture_at(pos: Vector2) -> Item:
	var items := get_node_or_null("Items")
	if items == null:
		return null
	for child in items.get_children():
		var it := child as Item
		if it == null:
			continue
		if str(it.data.get("interaction", "")).is_empty():
			continue
		if it.zone_rect().has_point(pos):
			return it
	return null


func _press_at(pos: Vector2) -> void:
	if _dragging:
		_release_at(_dragging.position)
	var c := _character_at(pos)
	if c != null:
		_start_character_drag(c, pos)
		return
	_try_plane(pos)


func _start_character_drag(c: Character, pos: Vector2) -> void:
	_dragging = c
	_drag_kind = DragKind.CHARACTER
	_drag_offset = c.position - pos
	_press_pos = pos
	_press_time = Time.get_ticks_msec()
	c.begin_drag()


## 点飞机：乘客在飞机上时，按住乘客可把 TA 拖下来；否则点击机身触发飞行
func _try_plane(pos: Vector2) -> void:
	var plane := get_node_or_null("Airplane")
	if plane == null:
		return
	var rider: Variant = plane.get("passenger")
	if rider != null:
		var p := rider as Character
		if p != null and Rect2(p.global_position + Vector2(-46, -152), Vector2(92, 160)).has_point(pos):
			var c := plane.unboard() as Character
			if c != null:
				_start_character_drag(c, pos)
			return
	if plane.hit_rect().has_point(pos):
		plane.click()


func _move_at(pos: Vector2) -> void:
	if _dragging == null:
		return
	if _drag_kind == DragKind.CHARACTER:
		_dragging.position = _clamp_room(pos + _drag_offset)
	else:
		_dragging.position = pos


func _release_at(pos: Vector2) -> void:
	if _dragging == null:
		return
	var target := _dragging
	var kind := _drag_kind
	_dragging = null
	_drag_kind = DragKind.NONE
	target.end_drag()
	if kind == DragKind.CHARACTER:
		var c := target as Character
		var moved := pos.distance_to(_press_pos) > 12.0
		var quick := Time.get_ticks_msec() - _press_time < 380
		if not moved and quick:
			_cycle_state(c)
			return
		_resolve_character_drop(c)
	else:
		_resolve_item_drop(target as Item, pos)


func _resolve_character_drop(c: Character) -> void:
	var furniture := _furniture_at(c.position)
	if furniture != null and InteractionManager.try_character_furniture(c, furniture):
		return
	var plane := get_node_or_null("Airplane")
	if plane != null and plane.get("passenger") == null and plane.hit_rect().has_point(c.position):
		plane.board(c)
		c.set_state(Character.State.IDLE)
		return
	c.set_state(Character.State.IDLE)


func _resolve_item_drop(item: Item, pos: Vector2) -> void:
	item.position = pos
	var target := _character_at(pos)
	if target != null and InteractionManager.try_character_item(target, item):
		_consume_item(item)
		return
	_return_item_to_bar(item)


func _consume_item(item: Node2D) -> void:
	var tw := item.create_tween()
	tw.tween_property(item, "scale", Vector2.ZERO, 0.18)
	tw.tween_callback(item.queue_free)


func _return_item_to_bar(item: Node2D) -> void:
	var target := Vector2(960, 980)
	var bar := get_node_or_null("ItemBar")
	if bar:
		for b in bar.get_children():
			if b is ItemButton and b.item_id == item.item_id:
				target = b.get_global_rect().get_center()
				break
	var tw := item.create_tween()
	tw.tween_property(item, "position", target, 0.25)
	tw.tween_property(item, "modulate:a", 0.0, 0.15)
	tw.tween_callback(item.queue_free)


func _cycle_state(c: Character) -> void:
	var idx: int = Character.STATE_CYCLE.find(c.state)
	c.set_state(Character.STATE_CYCLE[(idx + 1) % Character.STATE_CYCLE.size()])
