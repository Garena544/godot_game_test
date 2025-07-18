extends Node
class_name GameManager

# 游戏管理器
# 负责控制游戏的整体状态和流程

signal game_state_changed(new_state)
signal scene_changed(scene_name)

enum GameState {
	MENU,
	PLAYING,
	DIALOGUE,
	INVENTORY,
	PAUSED
}

var current_state: GameState = GameState.MENU
var current_scene: String = ""
var player_data: Dictionary = {}
var game_data: Dictionary = {}

# 单例模式
static var instance: GameManager

func _ready():
	instance = self
	# 确保这个节点不会被删除
	process_mode = Node.PROCESS_MODE_ALWAYS

func initialize():
	"""初始化游戏管理器"""
	print("游戏管理器初始化...")
	
	# 加载游戏数据
	load_game_data()
	
	# 设置初始状态
	change_state(GameState.PLAYING)

func start_game():
	"""开始游戏"""
	print("开始游戏...")
	
	# 开始初始对话
	var dialogue_manager = get_node("../DialogueManager")
	dialogue_manager.start_dialogue("wake_up")

func change_state(new_state: GameState):
	"""改变游戏状态"""
	if current_state != new_state:
		current_state = new_state
		game_state_changed.emit(new_state)
		print("游戏状态改变: ", GameState.keys()[new_state])

func load_scene(scene_name: String):
	"""加载场景"""
	current_scene = scene_name
	var scene_manager = get_node("../SceneManager")
	scene_manager.load_scene(scene_name)
	scene_changed.emit(scene_name)

func save_game():
	"""保存游戏"""
	var save_data = {
		"player_data": player_data,
		"game_data": game_data,
		"current_scene": current_scene,
		"current_state": current_state
	}
	
	var save_manager = get_node("../SaveManager")
	save_manager.save_game(save_data)

func load_game():
	"""加载游戏"""
	var save_manager = get_node("../SaveManager")
	var save_data = save_manager.load_game()
	if save_data:
		player_data = save_data.get("player_data", {})
		game_data = save_data.get("game_data", {})
		current_scene = save_data.get("current_scene", "start_room")
		current_state = save_data.get("current_state", GameState.PLAYING)
		
		load_scene(current_scene)

func load_game_data():
	"""加载游戏数据"""
	# 这里可以加载游戏配置、对话数据等
	game_data = {
		"game_name": "文字探险游戏",
		"version": "1.0.0"
	}

func get_current_state() -> GameState:
	return current_state

func is_in_dialogue() -> bool:
	return current_state == GameState.DIALOGUE

func is_in_inventory() -> bool:
	return current_state == GameState.INVENTORY

func end_game():
	"""结束游戏"""
	print("游戏结束")
	
	# 获取对话管理器来显示结束界面
	var dialogue_manager = get_node("../DialogueManager")
	dialogue_manager.show_end_summary() 
