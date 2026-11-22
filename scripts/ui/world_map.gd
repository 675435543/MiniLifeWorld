extends Control
## 世界地图：三个可点击建筑，配置来自 data/scenes.json。

const BUILDINGS := [
	["Center/HBox/HomeBtn", "home"],
	["Center/HBox/HospitalBtn", "hospital"],
	["Center/HBox/SchoolBtn", "school"],
	["Center/HBox/PlaygroundBtn", "playground"],
	["Center/HBox/RestaurantBtn", "restaurant"],
	["Center/HBox/AirportBtn", "airport"],
]


func _ready() -> void:
	for entry in BUILDINGS:
		var btn := get_node_or_null(entry[0]) as Button
		if btn == null:
			push_error("地图按钮缺失: " + str(entry[0]))
			continue
		var scene_id: String = entry[1]
		_apply_building(btn, scene_id)


func _apply_building(btn: Button, scene_id: String) -> void:
	var info: Dictionary = GameData.scenes.get(scene_id, {})
	btn.text = str(info.get("name", scene_id))
	var col := Color(str(info.get("building_color", "#FFB74D")))
	_style_button(btn, col.lerp(Color.WHITE, 0.45))
	btn.pressed.connect(func() -> void: SceneManager.enter_scene(scene_id))


func _style_button(btn: Button, fill: Color) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.set_corner_radius_all(32)
	sb.set_border_width_all(6)
	sb.border_color = Color(0.364, 0.251, 0.157, 1)
	for style_name in ["normal", "hover", "pressed"]:
		btn.add_theme_stylebox_override(style_name, sb)
	for color_name in ["font_color", "font_hover_color", "font_pressed_color"]:
		btn.add_theme_color_override(color_name, Color(0.364, 0.251, 0.157, 1))
