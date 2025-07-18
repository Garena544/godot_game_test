extends Node
class_name SaveManager

# 存档管理器
# 负责处理游戏的保存和加载功能

const SAVE_FILE_PATH = "user://savegame.save"
const SAVE_VERSION = "1.0"

signal game_saved(success: bool)
signal game_loaded(success: bool)

func save_game(save_data: Dictionary):
	"""保存游戏"""
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		# 添加版本信息
		save_data["version"] = SAVE_VERSION
		save_data["save_time"] = Time.get_datetime_string_from_system()
		
		# 转换为JSON并保存
		var json_string = JSON.stringify(save_data)
		file.store_string(json_string)
		file.close()
		
		print("游戏已保存")
		game_saved.emit(true)
		return true
	else:
		print("保存游戏失败")
		game_saved.emit(false)
		return false

func load_game() -> Dictionary:
	"""加载游戏"""
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var save_data = json.data
			
			# 检查版本兼容性
			if save_data.has("version"):
				var version = save_data["version"]
				if version == SAVE_VERSION:
					print("游戏加载成功")
					game_loaded.emit(true)
					return save_data
				else:
					print("存档版本不兼容: ", version)
					game_loaded.emit(false)
					return {}
			else:
				print("存档文件格式错误")
				game_loaded.emit(false)
				return {}
		else:
			print("解析存档文件失败")
			game_loaded.emit(false)
			return {}
	else:
		print("没有找到存档文件")
		game_loaded.emit(false)
		return {}

func has_save_file() -> bool:
	"""检查是否存在存档文件"""
	return FileAccess.file_exists(SAVE_FILE_PATH)

func delete_save_file():
	"""删除存档文件"""
	if has_save_file():
		var dir = DirAccess.open("user://")
		if dir:
			dir.remove("savegame.save")
			print("存档文件已删除")

func get_save_info() -> Dictionary:
	"""获取存档信息"""
	if has_save_file():
		var save_data = load_game()
		if save_data.size() > 0:
			return {
				"exists": true,
				"version": save_data.get("version", "未知"),
				"save_time": save_data.get("save_time", "未知"),
				"current_scene": save_data.get("current_scene", "未知"),
				"player_data": save_data.get("player_data", {})
			}
	
	return {
		"exists": false,
		"version": "",
		"save_time": "",
		"current_scene": "",
		"player_data": {}
	}

func create_auto_save():
	"""创建自动存档"""
	var game_manager = get_node("../GameManager")
	var inventory_manager = get_node("../InventoryManager")
	var scene_manager = get_node("../SceneManager")
	
	var auto_save_data = {
		"player_data": game_manager.player_data,
		"game_data": game_manager.game_data,
		"current_scene": game_manager.current_scene,
		"current_state": game_manager.current_state,
		"inventory": inventory_manager.save_inventory(),
		"scene_data": scene_manager.save_scene_data(),
		"auto_save": true
	}
	
	save_game(auto_save_data)

func load_auto_save() -> bool:
	"""加载自动存档"""
	var save_data = load_game()
	if save_data.size() > 0 and save_data.get("auto_save", false):
		var game_manager = get_node("../GameManager")
		var inventory_manager = get_node("../InventoryManager")
		var scene_manager = get_node("../SceneManager")
		
		# 恢复游戏状态
		game_manager.player_data = save_data.get("player_data", {})
		game_manager.game_data = save_data.get("game_data", {})
		game_manager.current_scene = save_data.get("current_scene", "start_room")
		game_manager.current_state = save_data.get("current_state", game_manager.GameState.PLAYING)
		
		# 恢复物品栏
		var inventory_data = save_data.get("inventory", {})
		inventory_manager.load_inventory(inventory_data)
		
		# 恢复场景数据
		var scene_data = save_data.get("scene_data", {})
		scene_manager.load_scene_data(scene_data)
		
		# 加载场景
		game_manager.load_scene(game_manager.current_scene)
		
		return true
	
	return false

func export_save_data() -> String:
	"""导出存档数据（用于备份）"""
	var save_data = load_game()
	if save_data.size() > 0:
		return JSON.stringify(save_data)
	return ""

func import_save_data(json_string: String) -> bool:
	"""导入存档数据（用于恢复备份）"""
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result == OK:
		var save_data = json.data
		return save_game(save_data)
	
	return false

func validate_save_data(save_data: Dictionary) -> bool:
	"""验证存档数据的完整性"""
	var required_fields = ["version", "player_data", "game_data", "current_scene"]
	
	for field in required_fields:
		if not save_data.has(field):
			print("存档数据缺少必要字段: ", field)
			return false
	
	return true 