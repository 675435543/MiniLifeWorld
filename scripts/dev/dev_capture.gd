extends Node
## 开发工具（Autoload: DevCapture）
## 通过命令行参数触发场景截图，用于里程碑视觉验收。
## 用法：godot --path . -- --capture-shots
## 截图保存到 res://.godot/dev_shots/（仅开发环境使用）。


func _ready() -> void:
	if not ("--capture-shots" in OS.get_cmdline_user_args()):
		set_process(false)
		return
	if DisplayServer.get_name() == "headless":
		push_warning("DevCapture 需要窗口模式才能截图，已跳过")
		set_process(false)
		return
	_run_capture.call_deferred()


func _run_capture() -> void:
	await get_tree().process_frame
	# 截图用干净存档，避免恢复上次运行留下的角色
	if FileAccess.file_exists("user://save.json"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://save.json"))
	SaveManager.data = SaveManager._default_data()
	await _capture_current("01_menu")

	var tree := get_tree()
	if tree.current_scene:
		tree.current_scene.visible = false
		tree.current_scene.queue_free()

	var cases := [
		["02_world_map", "res://scenes/main/world_map.tscn"],
		["03_home", "res://scenes/home/home.tscn"],
		["04_hospital", "res://scenes/hospital/hospital.tscn"],
		["05_school", "res://scenes/school/school.tscn"],
		["06_playground", "res://scenes/playground/playground.tscn"],
		["07_restaurant", "res://scenes/restaurant/restaurant.tscn"],
	]
	for c in cases:
		var ps := load(c[1]) as PackedScene
		if ps == null:
			continue
		var inst := ps.instantiate()
		tree.root.add_child(inst)
		tree.current_scene = inst
		await _capture_current(c[0])
		if c[0] == "03_home":
			_log_layout(inst)
		inst.visible = false
		inst.queue_free()
		await tree.process_frame

	get_tree().quit()


func _log_layout(room: Node) -> void:
	var bar := room.get_node_or_null("AvatarBar")
	if bar:
		print("DEV_LAYOUT: AvatarBar pos=", bar.position, " size=", bar.size)
		for child in bar.get_children():
			print("DEV_LAYOUT: avatar id=", child.get("char_id"), " pos=", child.position, " size=", child.size)
	var chars := room.get_node_or_null("Characters")
	if chars:
		for c in chars.get_children():
			print("DEV_LAYOUT: character id=", c.get("char_id"), " pos=", c.position)


func _capture_current(shot_name: String) -> void:
	for i in range(6):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	var dir := "res://.godot/dev_shots"
	DirAccess.make_dir_recursive_absolute(dir)
	var path := dir + "/" + shot_name + ".png"
	var err := img.save_png(path)
	if err != OK:
		push_error("截图保存失败: " + path)
	else:
		print("DEV_CAPTURE: " + path)
