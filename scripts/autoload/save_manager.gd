extends Node
## 存档管理（Autoload: SaveManager）
## 存档写入 user://save.json，场景切换/退出时自动保存。

const SAVE_PATH := "user://save.json"

var data: Dictionary = {}


func _ready() -> void:
	data = _default_data()
	load_game()


func _default_data() -> Dictionary:
	return {
		"version": 1,
		"unlocked_scenes": ["home", "hospital", "school"],
		"current_scene": "world_map",
		"scene_states": {},
		"settings": {"sfx": true, "music": true},
		"tutorial_seen": false,
	}


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var text := FileAccess.get_file_as_string(SAVE_PATH)
	var json := JSON.new()
	if json.parse(text) != OK or typeof(json.data) != TYPE_DICTIONARY:
		push_warning("存档损坏，使用默认存档")
		return
	for key in json.data:
		data[key] = json.data[key]


func save_game() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_warning("无法写入存档: " + SAVE_PATH)
		return
	f.store_string(JSON.stringify(data, "\t"))
	f.close()


func mark_tutorial_seen() -> void:
	data["tutorial_seen"] = true
	save_game()
