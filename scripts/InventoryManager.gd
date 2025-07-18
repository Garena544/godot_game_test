extends Node
class_name InventoryManager

# 物品管理器
# 负责管理游戏中的物品系统

signal item_added(item_id)
signal item_removed(item_id)
signal item_used(item_id)

var inventory: Dictionary = {}
var max_inventory_size: int = 20

# 物品数据
var item_database: Dictionary = {
	"key": {
		"name": "钥匙",
		"description": "一把可以打开门的钥匙",
		"type": "tool",
		"usable": true
	},
	"diary": {
		"name": "日记",
		"description": "一本古老的日记，记录着重要的信息",
		"type": "document",
		"usable": true
	},
	"flashlight": {
		"name": "手电筒",
		"description": "一个手电筒，可以在黑暗中照明",
		"type": "tool",
		"usable": true
	},
	"map": {
		"name": "地图",
		"description": "一张神秘的地图，显示着隐藏的路径",
		"type": "document",
		"usable": true
	}
}

func _ready():
	# 初始化物品栏
	initialize_inventory()

func initialize_inventory():
	"""初始化物品栏"""
	inventory.clear()
	print("物品栏初始化完成")

func add_item(item_id: String, item_name: String = "", description: String = ""):
	"""添加物品到物品栏"""
	if inventory.size() >= max_inventory_size:
		print("物品栏已满！")
		return false
	
	# 如果提供了自定义名称和描述，使用它们
	if item_name != "" and description != "":
		inventory[item_id] = {
			"name": item_name,
			"description": description,
			"type": "custom",
			"usable": true
		}
	else:
		# 使用数据库中的物品信息
		if item_id in item_database:
			inventory[item_id] = item_database[item_id].duplicate()
		else:
			print("物品不存在: ", item_id)
			return false
	
	item_added.emit(item_id)
	print("获得物品: ", inventory[item_id]["name"])
	return true

func remove_item(item_id: String):
	"""从物品栏移除物品"""
	if has_item(item_id):
		var item_name = inventory[item_id]["name"]
		inventory.erase(item_id)
		item_removed.emit(item_id)
		print("移除物品: ", item_name)
		return true
	return false

func use_item(item_id: String):
	"""使用物品"""
	if has_item(item_id):
		var item = inventory[item_id]
		if item.get("usable", false):
			item_used.emit(item_id)
			print("使用物品: ", item["name"])
			
			# 根据物品类型执行不同操作
			match item["type"]:
				"tool":
					handle_tool_usage(item_id)
				"document":
					handle_document_usage(item_id)
				_:
					print("未知物品类型: ", item["type"])
			
			return true
		else:
			print("该物品无法使用")
			return false
	return false

func handle_tool_usage(item_id: String):
	"""处理工具类物品的使用"""
	match item_id:
		"key":
			# 钥匙的使用逻辑在对话管理器中处理
			pass
		"flashlight":
			# 手电筒效果
			var ui_manager = get_node("../UIManager")
			ui_manager.show_message("你打开了手电筒，周围变得明亮起来。")
		_:
			print("未知工具: ", item_id)

func handle_document_usage(item_id: String):
	"""处理文档类物品的使用"""
	match item_id:
		"diary":
			# 显示日记内容
			var dialogue_manager = get_node("../DialogueManager")
			dialogue_manager.show_diary_content()
		"map":
			# 显示地图
			show_map_content()
		_:
			print("未知文档: ", item_id)

func show_map_content():
	"""显示地图内容"""
	var map_text = "地图内容：\n\n你看到地图上标记着几个重要的位置：\n- 起始房间\n- 走廊\n- 图书馆\n- 出口\n\n地图显示有一条秘密通道通向出口。"
	
	var ui_manager = get_node("../UIManager")
	ui_manager.show_dialogue(map_text)
	
	# 添加继续选项
	var continue_choice = {"id": "continue_exploring", "text": "继续探索"}
	ui_manager.show_choices([continue_choice])

func has_item(item_id: String) -> bool:
	"""检查是否拥有指定物品"""
	return item_id in inventory

func get_item(item_id: String) -> Dictionary:
	"""获取物品信息"""
	return inventory.get(item_id, {})

func get_all_items() -> Dictionary:
	"""获取所有物品"""
	return inventory.duplicate()

func get_items_by_type(item_type: String) -> Dictionary:
	"""根据类型获取物品"""
	var filtered_items = {}
	for item_id in inventory:
		if inventory[item_id]["type"] == item_type:
			filtered_items[item_id] = inventory[item_id]
	return filtered_items

func get_inventory_size() -> int:
	"""获取物品栏大小"""
	return inventory.size()

func is_inventory_full() -> bool:
	"""检查物品栏是否已满"""
	return inventory.size() >= max_inventory_size

func clear_inventory():
	"""清空物品栏"""
	inventory.clear()
	print("物品栏已清空")

func save_inventory() -> Dictionary:
	"""保存物品栏数据"""
	return inventory.duplicate()

func load_inventory(saved_inventory: Dictionary):
	"""加载物品栏数据"""
	inventory = saved_inventory.duplicate()
	print("物品栏数据已加载") 
