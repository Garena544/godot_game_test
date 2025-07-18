extends Node2D

# 主场景脚本
# 负责初始化游戏和协调各个系统

func _ready():
	print("主场景已加载")
	
	# 等待一帧确保所有节点都已准备好
	await get_tree().process_frame
	
	# 获取GameManager实例
	var game_manager = get_node("GameManager")
	
	# 初始化游戏管理器
	game_manager.initialize()
	
	# 开始游戏
	game_manager.start_game()
	
	# 强制显示对话
	call_deferred("force_show_dialogue")
	
	# 添加测试按钮到UI管理器
	call_deferred("add_test_buttons")

func add_test_buttons():
	"""添加测试按钮到UI管理器"""
	var ui_manager = get_node("UIManager")
	ui_manager.add_test_buttons()

func force_show_dialogue():
	"""强制显示对话界面"""
	print("强制显示对话界面")
	var dialogue_manager = get_node("DialogueManager")
	dialogue_manager.start_dialogue("wake_up")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		# 继续对话
		var dialogue_manager = get_node("DialogueManager")
		dialogue_manager.continue_dialogue()
		print("按下了确认键")
	
	if event.is_action_pressed("inventory"):
		# 切换物品栏显示
		var ui_manager = get_node("UIManager")
		ui_manager.toggle_inventory()
		print("按下了物品栏键") 
