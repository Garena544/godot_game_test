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
	
	# 添加测试按钮
	call_deferred("add_test_buttons")

func add_test_buttons():
	"""添加测试按钮"""
	# 创建测试LM Studio按钮
	var test_button = Button.new()
	test_button.text = "测试LM Studio连接"
	test_button.position = Vector2(20, 100)
	test_button.custom_minimum_size = Vector2(200, 40)
	test_button.add_theme_font_size_override("font_size", 16)
	test_button.connect("pressed", _on_test_lm_studio)
	add_child(test_button)
	
	# 创建自由对话按钮
	var free_dialogue_button = Button.new()
	free_dialogue_button.text = "开始自由对话"
	free_dialogue_button.position = Vector2(20, 150)
	free_dialogue_button.custom_minimum_size = Vector2(200, 40)
	free_dialogue_button.add_theme_font_size_override("font_size", 16)
	free_dialogue_button.connect("pressed", _on_start_free_dialogue)
	add_child(free_dialogue_button)
	
	# 创建启用LLM对话按钮
	var llm_dialogue_button = Button.new()
	llm_dialogue_button.text = "启用LLM对话"
	llm_dialogue_button.position = Vector2(20, 200)
	llm_dialogue_button.custom_minimum_size = Vector2(200, 40)
	llm_dialogue_button.add_theme_font_size_override("font_size", 16)
	llm_dialogue_button.connect("pressed", _on_enable_llm_dialogue)
	add_child(llm_dialogue_button)
	
	print("测试按钮已添加")

func _on_test_lm_studio():
	"""测试LM Studio连接"""
	print("开始测试LM Studio连接...")
	var test_script = load("res://scripts/LMStudioTest.gd").new()
	add_child(test_script)

func _on_start_free_dialogue():
	"""开始自由对话"""
	print("开始自由对话...")
	var dialogue_manager = get_node("DialogueManager")
	dialogue_manager.start_free_dialogue()

func _on_enable_llm_dialogue():
	"""启用LLM对话"""
	print("启用LLM对话...")
	var dialogue_manager = get_node("DialogueManager")
	dialogue_manager.enable_llm_dialogue()

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
