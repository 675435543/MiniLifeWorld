extends SceneTree
## 字体验收：端到端确认主题字体能渲染中文（避免出现"豆腐块"）。
## 用法：godot --headless --path . --script res://tests/font_check.gd


func _initialize() -> void:
	var ok := true
	# 1. 主题资源与 SystemFont 可加载，且覆盖常用中文字形
	var theme := load("res://assets/ui/main_theme.tres") as Theme
	if theme == null or theme.default_font == null:
		print("FONT_CHECK: FAIL 主题或字体缺失")
		ok = false
	else:
		var bad := []
		for c in ["我", "妈", "开", "始", "游", "戏", "家", "医", "院", "学", "校", "地", "图"]:
			if not theme.default_font.has_char(c.unicode_at(0)):
				bad.append(c)
		if bad.is_empty():
			print("FONT_CHECK: 主题字体包含全部中文字形")
		else:
			print("FONT_CHECK: 缺少字形 " + str(bad))
			ok = false

	# 2. 端到端：真实控件解析到的字体也包含中文
	var menu: Control = load("res://scenes/main/main_menu.tscn").instantiate()
	root.add_child(menu)
	var subtitle := menu.get_node("Center/VBox/Subtitle") as Label
	if subtitle:
		var font := subtitle.get_theme_font("font")
		var has := font != null and font.has_char("我".unicode_at(0))
		print("FONT_CHECK: 控件有效字体包含中文 = " + str(has))
		if not has:
			ok = false
	menu.queue_free()

	quit(0 if ok else 1)
