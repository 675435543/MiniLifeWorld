extends SceneTree
## 冒烟测试：校验数据配置与所有场景可加载、可实例化。
## 用法：godot --headless --path . --script res://tests/smoke_test.gd
## 输出 SMOKE_TEST: PASS / FAIL，失败时退出码非 0。


func _initialize() -> void:
	var ok := true
	ok = _check_data() and ok
	ok = _check_scenes() and ok
	ok = _check_scripts() and ok
	print("SMOKE_TEST: " + ("PASS" if ok else "FAIL"))
	quit(0 if ok else 1)


func _check_scripts() -> bool:
	var ok := true
	for s in [
		"res://scripts/characters/character.gd",
		"res://scripts/ui/avatar_button.gd",
		"res://scripts/items/prop_draw.gd",
	]:
		if load(s) == null:
			push_error("脚本加载失败: " + str(s))
			ok = false
	return ok


func _check_data() -> bool:
	var ok := true
	for f in ["characters.json", "items.json", "scenes.json"]:
		var p: String = "res://data/" + str(f)
		if not FileAccess.file_exists(p):
			push_error("数据文件缺失: " + p)
			ok = false
			continue
		var json := JSON.new()
		if json.parse(FileAccess.get_file_as_string(p)) != OK:
			push_error("JSON 解析失败: " + p)
			ok = false
	return ok


func _check_scenes() -> bool:
	var paths: Array[String] = [
		"res://scenes/main/main_menu.tscn",
		"res://scenes/main/world_map.tscn",
		"res://scenes/home/home.tscn",
		"res://scenes/hospital/hospital.tscn",
		"res://scenes/school/school.tscn",
		"res://scenes/playground/playground.tscn",
		"res://scenes/restaurant/restaurant.tscn",
		"res://scenes/characters/character.tscn",
	]
	var ok := true
	for p in paths:
		if not ResourceLoader.exists(p):
			push_error("场景缺失: " + p)
			ok = false
			continue
		var ps := load(p) as PackedScene
		if ps == null:
			push_error("场景加载失败: " + p)
			ok = false
			continue
		var inst := ps.instantiate()
		if inst == null:
			push_error("场景实例化失败: " + p)
			ok = false
			continue
		inst.free()
	# 校验 scenes.json 中引用的场景路径存在
	var text := FileAccess.get_file_as_string("res://data/scenes.json")
	var json := JSON.new()
	if json.parse(text) == OK and typeof(json.data) == TYPE_DICTIONARY:
		for id in json.data:
			var info: Dictionary = json.data[id]
			var p := str(info.get("path", ""))
			if p.is_empty() or not ResourceLoader.exists(p):
				push_error("场景 %s 的 path 无效: %s" % [str(id), p])
				ok = false
	return ok
