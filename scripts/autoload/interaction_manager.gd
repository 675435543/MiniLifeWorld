extends Node
## 交互系统（Autoload: InteractionManager）
## 统一规则表：角色 × 家具 / 角色 × 道具，数据来自 data/items.json 的 interaction 字段。

## 道具 interaction 字段 -> 角色状态（供调试与未来扩展）
var _state_map: Dictionary = {
	"eat": "eat",
	"drink": "eat",
	"sit": "sit",
	"sleep": "sleep",
	"read": "interact",
	"play": "happy",
	"use": "interact",
	"wear": "happy",
	"examine": "interact",
}


func state_for(interaction: String) -> String:
	return str(_state_map.get(interaction, "interact"))


## 角色落在家具上：床→躺下、沙发/椅子→坐下、电视等→开心互动
func try_character_furniture(c: Character, item: Item) -> bool:
	var inter := str(item.data.get("interaction", ""))
	match inter:
		"sleep":
			c.set_state(Character.State.SLEEP)
			c.position = item.zone_rect().get_center() + Vector2(0, 16)
			return true
		"sit":
			c.set_state(Character.State.SIT)
			c.position = item.zone_rect().get_center() + Vector2(0, 14)
			return true
		"slide":
			c.set_state(Character.State.HAPPY)
			var tw := c.create_tween()
			tw.tween_property(c, "position", item.zone_rect().get_center() + Vector2(-130, 40), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			return true
		"swing":
			c.set_state(Character.State.SIT)
			_swing_loop(c)
			return true
		"seesaw":
			c.set_state(Character.State.SIT)
			var tw2 := c.create_tween()
			tw2.tween_property(c, "rotation", 0.12, 0.45)
			tw2.tween_property(c, "rotation", -0.12, 0.45)
			tw2.tween_property(c, "rotation", 0.0, 0.45)
			return true
		"use", "read", "play":
			c.set_state(Character.State.HAPPY)
			return true
	return false


func _swing_loop(c: Character) -> void:
	var tw := c.create_tween()
	tw.tween_property(c, "rotation", 0.22, 0.45)
	tw.tween_property(c, "rotation", -0.22, 0.45)
	tw.tween_property(c, "rotation", 0.0, 0.45)


## 道具拖到角色身上：食物→吃、水→喝、衣服→换装
func try_character_item(c: Character, item: Item) -> bool:
	var inter := str(item.data.get("interaction", ""))
	match inter:
		"eat", "drink":
			c.set_state(Character.State.EAT)
			return true
		"wear":
			var d := item.data
			if d.has("shirt"):
				c.apply_outfit(Color(str(d["shirt"])))
			if d.has("skirt"):
				c.apply_skirt(Color(str(d["skirt"])))
			if d.has("scarf"):
				c.apply_scarf(Color(str(d["scarf"])))
			if d.has("gloves"):
				c.apply_gloves(Color(str(d["gloves"])))
			c.set_state(Character.State.HAPPY)
			return true
		"play":
			c.set_state(Character.State.HAPPY)
			return true
		"read", "use", "examine":
			c.set_state(Character.State.INTERACT)
			return true
	return false
