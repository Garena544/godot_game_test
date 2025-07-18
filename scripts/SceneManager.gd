extends Node
class_name SceneManager

# 场景管理器
# 负责管理不同游戏场景的切换和加载

signal scene_loaded(scene_name)
signal scene_unloaded(scene_name)

var current_scene: String = ""
var scene_data: Dictionary = {}

# 场景数据
var scenes: Dictionary = {
	"start_room": {
		"name": "起始房间",
		"description": "一个神秘的房间，房间里有一扇门、一张桌子和一个书架。",
		"interactables": ["door", "table", "bookshelf"],
		"connections": {
			"corridor": "门通向走廊"
		}
	},
	"corridor": {
		"name": "走廊",
		"description": "一条黑暗的走廊，墙壁上挂着古老的画作。走廊尽头有一扇门。",
		"interactables": ["paintings", "door", "light_switch"],
		"connections": {
			"start_room": "回到起始房间",
			"library": "通向图书馆"
		},
		"required_items": ["flashlight"]
	},
	"library": {
		"name": "图书馆",
		"description": "一个巨大的图书馆，书架上摆满了古老的书籍。房间中央有一张桌子。",
		"interactables": ["bookshelves", "table", "exit_door"],
		"connections": {
			"corridor": "回到走廊"
		}
	}
}

func _ready():
	# 初始化场景管理器
	initialize_scenes()

func initialize_scenes():
	"""初始化场景数据"""
	print("场景管理器初始化完成")

func load_scene(scene_name: String):
	"""加载场景"""
	if scene_name in scenes:
		# 检查场景要求
		if can_enter_scene(scene_name):
			current_scene = scene_name
			var scene_info = scenes[scene_name]
			
			# 更新场景描述
			update_scene_description(scene_info)
			
			# 触发场景加载事件
			scene_loaded.emit(scene_name)
			
			print("加载场景: ", scene_info["name"])
			
			# 开始场景特定的对话
			start_scene_dialogue(scene_name)
		else:
			print("无法进入场景: ", scene_name, " - 缺少必要物品")
			show_scene_requirement(scene_name)
	else:
		print("场景不存在: ", scene_name)

func can_enter_scene(scene_name: String) -> bool:
	"""检查是否可以进入场景"""
	var scene_info = scenes.get(scene_name, {})
	var required_items = scene_info.get("required_items", [])
	
	var inventory_manager = get_node("../InventoryManager")
	for item_id in required_items:
		if not inventory_manager.has_item(item_id):
			return false
	
	return true

func show_scene_requirement(scene_name: String):
	"""显示场景要求"""
	var scene_info = scenes.get(scene_name, {})
	var required_items = scene_info.get("required_items", [])
	
	var inventory_manager = get_node("../InventoryManager")
	var missing_items = []
	for item_id in required_items:
		if not inventory_manager.has_item(item_id):
			missing_items.append(item_id)
	
	var message = "无法进入" + scene_info["name"] + "。\n\n需要物品："
	for item_id in missing_items:
		message += "\n- " + get_item_name(item_id)
	
	var ui_manager = get_node("../UIManager")
	ui_manager.show_dialogue(message)
	
	# 添加返回选项
	var back_choice = {"id": "back_to_previous", "text": "返回"}
	ui_manager.show_choices([back_choice])

func get_item_name(item_id: String) -> String:
	"""获取物品名称"""
	var inventory_manager = get_node("../InventoryManager")
	var item = inventory_manager.get_item(item_id)
	if item.has("name"):
		return item["name"]
	else:
		# 从物品数据库获取
		var item_data = inventory_manager.item_database.get(item_id, {})
		return item_data.get("name", item_id)

func update_scene_description(scene_info: Dictionary):
	"""更新场景描述"""
	var description = scene_info["description"]
	var ui_manager = get_node("../UIManager")
	ui_manager.show_message("进入" + scene_info["name"] + "\n\n" + description, 3.0)

func start_scene_dialogue(scene_name: String):
	"""开始场景特定的对话"""
	var dialogue_manager = get_node("../DialogueManager")
	match scene_name:
		"start_room":
			dialogue_manager.start_dialogue("welcome")
		"corridor":
			start_corridor_dialogue()
		"library":
			start_library_dialogue()

func start_corridor_dialogue():
	"""开始走廊对话"""
	var corridor_text = "你进入了黑暗的走廊。\n\n墙壁上挂着几幅古老的画作，走廊尽头有一扇门。\n\n你注意到墙上有一个电灯开关。"
	
	var ui_manager = get_node("../UIManager")
	ui_manager.show_dialogue(corridor_text)
	
	var choices = [
		{"id": "examine_paintings", "text": "查看画作"},
		{"id": "use_light_switch", "text": "使用电灯开关"},
		{"id": "go_to_library", "text": "前往图书馆"},
		{"id": "return_to_room", "text": "返回起始房间"}
	]
	
	ui_manager.show_choices(choices)

func start_library_dialogue():
	"""开始图书馆对话"""
	var library_text = "你进入了巨大的图书馆。\n\n书架上摆满了古老的书籍，房间中央有一张桌子，上面放着一本特别的书。\n\n房间的另一端有一扇门，可能是出口。"
	
	var ui_manager = get_node("../UIManager")
	ui_manager.show_dialogue(library_text)
	
	var choices = [
		{"id": "examine_books", "text": "查看书籍"},
		{"id": "read_special_book", "text": "阅读桌上的书"},
		{"id": "check_exit", "text": "检查出口"},
		{"id": "return_to_corridor", "text": "返回走廊"}
	]
	
	ui_manager.show_choices(choices)

func get_current_scene() -> String:
	"""获取当前场景"""
	return current_scene

func get_scene_info(scene_name: String) -> Dictionary:
	"""获取场景信息"""
	return scenes.get(scene_name, {})

func get_available_connections(scene_name: String) -> Dictionary:
	"""获取场景可用的连接"""
	var scene_info = scenes.get(scene_name, {})
	return scene_info.get("connections", {})

func add_scene(scene_name: String, scene_data: Dictionary):
	"""添加新场景"""
	scenes[scene_name] = scene_data
	print("添加场景: ", scene_name)

func remove_scene(scene_name: String):
	"""移除场景"""
	if scene_name in scenes:
		scenes.erase(scene_name)
		print("移除场景: ", scene_name)

func get_all_scenes() -> Dictionary:
	"""获取所有场景"""
	return scenes.duplicate()

func save_scene_data() -> Dictionary:
	"""保存场景数据"""
	return {
		"current_scene": current_scene,
		"scenes": scenes.duplicate()
	}

func load_scene_data(saved_data: Dictionary):
	"""加载场景数据"""
	current_scene = saved_data.get("current_scene", "")
	scenes = saved_data.get("scenes", {}).duplicate()
	print("场景数据已加载") 
