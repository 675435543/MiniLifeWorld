extends Node
## 场景切换（Autoload: SceneManager）
## 负责世界地图与各场景之间的淡入淡出切换。

const MAP_PATH := "res://scenes/main/world_map.tscn"

var _fade_layer: CanvasLayer
var _fade_rect: ColorRect
var _transitioning := false


func _ready() -> void:
	_fade_layer = CanvasLayer.new()
	_fade_layer.name = "FadeLayer"
	_fade_layer.layer = 100
	add_child(_fade_layer)

	_fade_rect = ColorRect.new()
	_fade_rect.name = "FadeRect"
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_layer.add_child(_fade_rect)
	_fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func enter_scene(scene_id: String) -> void:
	var info: Dictionary = GameData.scenes.get(scene_id, {})
	var path := str(info.get("path", ""))
	if path.is_empty() or not ResourceLoader.exists(path):
		push_error("无法进入场景 %s：路径无效 %s" % [scene_id, path])
		return
	SaveManager.data["current_scene"] = scene_id
	await _change_to(path)


func go_to_map() -> void:
	SaveManager.data["current_scene"] = "world_map"
	await _change_to(MAP_PATH)


func _change_to(path: String) -> void:
	if _transitioning:
		return
	_transitioning = true
	await _fade_to(1.0)
	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("场景切换失败: " + path)
		_transitioning = false
		await _fade_to(0.0)
		return
	await get_tree().process_frame
	await _fade_to(0.0)
	_transitioning = false
	SaveManager.save_game()


func _fade_to(alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(_fade_rect, "color:a", alpha, 0.25)
	await tween.finished
