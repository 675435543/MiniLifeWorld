extends Node
## 全局配置数据（Autoload: GameData）
## 负责加载 data/ 下的 JSON 并做基础校验。

const DATA_DIR := "res://data/"

var characters: Dictionary = {}
var items: Dictionary = {}
var scenes: Dictionary = {}


func _ready() -> void:
	characters = _load_json("characters.json")
	items = _load_json("items.json")
	scenes = _load_json("scenes.json")
	_validate()
	print("GameData 就绪：角色 %d / 道具 %d / 场景 %d" % [characters.size(), items.size(), scenes.size()])


func _load_json(file_name: String) -> Dictionary:
	var path := DATA_DIR + file_name
	if not FileAccess.file_exists(path):
		push_error("数据文件缺失: " + path)
		return {}
	var text := FileAccess.get_file_as_string(path)
	var json := JSON.new()
	if json.parse(text) != OK:
		push_error("JSON 解析失败 %s: %s (行 %d)" % [path, json.get_error_message(), json.get_error_line()])
		return {}
	if typeof(json.data) != TYPE_DICTIONARY:
		push_error("数据格式错误（应为 JSON 对象）: " + path)
		return {}
	return json.data


func _validate() -> void:
	for id in characters:
		if not characters[id] is Dictionary:
			push_error("角色配置格式错误: " + str(id))
	for id in items:
		if not items[id] is Dictionary:
			push_error("道具配置格式错误: " + str(id))
	for id in scenes:
		var info: Dictionary = scenes[id]
		if str(info.get("path", "")).is_empty():
			push_error("场景 %s 缺少 path" % str(id))
