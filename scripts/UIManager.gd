extends CanvasLayer
class_name UIManager

# UI管理器
# 负责管理游戏的所有用户界面

signal choice_selected(choice_id)
signal message_sent(message: String)

var dialogue_panel: Panel
var dialogue_text: RichTextLabel
var choice_container: VBoxContainer
var inventory_panel: Panel
var inventory_list: VBoxContainer
var time_label: Label
var background_texture: TextureRect

# 自由对话UI组件
var free_dialogue_panel: Panel
var message_input: LineEdit
var send_button: Button
var chat_container: VBoxContainer
var scroll_container: ScrollContainer

func _ready():
	# 获取UI节点引用
	dialogue_panel = $DialogueUI/DialoguePanel
	dialogue_text = $DialogueUI/DialoguePanel/DialogueText
	choice_container = $DialogueUI/DialoguePanel/ChoiceContainer
	inventory_panel = $InventoryUI/InventoryPanel
	inventory_list = $InventoryUI/InventoryPanel/InventoryList
	
	# 创建时间显示标签
	create_time_display()
	
	# 创建背景图片
	create_background()
	
	# 创建自由对话UI
	create_free_dialogue_ui()
	
	# 初始隐藏物品栏，但保持对话UI可见
	hide_inventory()
	
	print("UIManager 初始化完成")

func add_test_buttons():
	"""添加测试按钮"""
	print("添加测试按钮到UI管理器")
	
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
	
	print("测试按钮已添加到UI管理器")

func _on_test_lm_studio():
	"""测试LM Studio连接"""
	print("开始测试LM Studio连接...")
	var test_script = load("res://scripts/LMStudioTest.gd").new()
	get_parent().add_child(test_script)

func _on_start_free_dialogue():
	"""开始自由对话"""
	print("开始自由对话...")
	var dialogue_manager = get_parent().get_node("DialogueManager")
	dialogue_manager.start_free_dialogue()

func _on_enable_llm_dialogue():
	"""启用LLM对话"""
	print("启用LLM对话...")
	var dialogue_manager = get_parent().get_node("DialogueManager")
	dialogue_manager.enable_llm_dialogue()

func create_free_dialogue_ui():
	"""创建自由对话UI"""
	# 创建自由对话面板
	free_dialogue_panel = Panel.new()
	free_dialogue_panel.anchors_preset = Control.PRESET_FULL_RECT
	free_dialogue_panel.offset_left = 50
	free_dialogue_panel.offset_top = 50
	free_dialogue_panel.offset_right = -50
	free_dialogue_panel.offset_bottom = -50
	free_dialogue_panel.visible = false
	
	# 设置面板样式
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.1, 0.1, 0.15, 0.9)
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.3, 0.3, 0.5)
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_left = 10
	style_box.corner_radius_bottom_right = 10
	free_dialogue_panel.add_theme_stylebox_override("panel", style_box)
	
	# 创建标题
	var title_label = Label.new()
	title_label.text = "自由对话模式"
	title_label.anchors_preset = Control.PRESET_TOP_WIDE
	title_label.offset_left = 20
	title_label.offset_top = 20
	title_label.offset_right = -20
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# 创建聊天容器
	scroll_container = ScrollContainer.new()
	scroll_container.anchors_preset = Control.PRESET_FULL_RECT
	scroll_container.offset_left = 20
	scroll_container.offset_top = 60
	scroll_container.offset_right = -20
	scroll_container.offset_bottom = -120
	
	chat_container = VBoxContainer.new()
	chat_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chat_container.add_theme_constant_override("separation", 10)
	
	scroll_container.add_child(chat_container)
	
	# 创建输入区域
	var input_container = HBoxContainer.new()
	input_container.anchors_preset = Control.PRESET_BOTTOM_WIDE
	input_container.offset_left = 20
	input_container.offset_bottom = -20
	input_container.offset_right = -20
	input_container.add_theme_constant_override("separation", 10)
	
	# 创建输入框
	message_input = LineEdit.new()
	message_input.placeholder_text = "输入你的消息..."
	message_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message_input.add_theme_font_size_override("font_size", 16)
	message_input.connect("text_submitted", _on_message_submitted)
	
	# 创建发送按钮
	send_button = Button.new()
	send_button.text = "发送"
	send_button.custom_minimum_size = Vector2(80, 40)
	send_button.add_theme_font_size_override("font_size", 16)
	send_button.connect("pressed", _on_send_button_pressed)
	
	# 创建返回按钮
	var back_button = Button.new()
	back_button.text = "返回"
	back_button.custom_minimum_size = Vector2(80, 40)
	back_button.add_theme_font_size_override("font_size", 16)
	back_button.connect("pressed", _on_back_button_pressed)
	
	# 添加组件到输入容器
	input_container.add_child(message_input)
	input_container.add_child(send_button)
	input_container.add_child(back_button)
	
	# 添加所有组件到面板
	free_dialogue_panel.add_child(title_label)
	free_dialogue_panel.add_child(scroll_container)
	free_dialogue_panel.add_child(input_container)
	
	# 添加到场景
	add_child(free_dialogue_panel)

func show_free_dialogue():
	"""显示自由对话界面"""
	free_dialogue_panel.show()
	message_input.grab_focus()
	print("显示自由对话界面")

func show_free_dialogue_with_context(context: String):
	"""显示带剧情上下文的自由对话界面"""
	free_dialogue_panel.show()
	message_input.grab_focus()
	
	# 显示剧情上下文
	add_context_message(context)
	print("显示带上下文的自由对话界面")

func hide_free_dialogue():
	"""隐藏自由对话界面"""
	free_dialogue_panel.hide()
	clear_chat_history()

func clear_chat_history():
	"""清除聊天历史"""
	for child in chat_container.get_children():
		child.queue_free()

func add_context_message(context: String):
	"""添加剧情上下文消息"""
	var context_label = Label.new()
	context_label.text = "剧情背景: " + context
	context_label.add_theme_font_size_override("font_size", 14)
	context_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	context_label.modulate = Color(0.8, 0.8, 1.0)
	context_label.custom_minimum_size = Vector2(0, 30)
	
	chat_container.add_child(context_label)
	scroll_to_bottom()

func add_user_message(message: String):
	"""添加用户消息到聊天界面"""
	var message_label = Label.new()
	message_label.text = "你: " + message
	message_label.add_theme_font_size_override("font_size", 16)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	message_label.modulate = Color(0.8, 0.9, 1.0)
	
	chat_container.add_child(message_label)
	scroll_to_bottom()

func add_ai_message(message: String):
	"""添加AI消息到聊天界面"""
	print("添加AI消息到聊天界面: ", message)
	
	var message_label = Label.new()
	message_label.text = "AI: " + message
	message_label.add_theme_font_size_override("font_size", 16)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	message_label.modulate = Color(1.0, 0.9, 0.8)
	
	print("创建AI消息标签完成")
	
	chat_container.add_child(message_label)
	print("AI消息已添加到聊天容器")
	
	scroll_to_bottom()
	print("滚动到底部完成")

func scroll_to_bottom():
	"""滚动到底部"""
	await get_tree().process_frame
	scroll_container.ensure_control_visible(chat_container.get_child(chat_container.get_child_count() - 1))

func _on_message_submitted(text: String):
	"""处理消息提交"""
	if text.strip_edges() != "":
		send_message(text)

func _on_send_button_pressed():
	"""处理发送按钮点击"""
	var text = message_input.text.strip_edges()
	if text != "":
		send_message(text)

func _on_back_button_pressed():
	"""处理返回按钮点击"""
	hide_free_dialogue()
	
	# 显示剧情选择
	show_story_choices()

func show_story_choices():
	"""显示剧情选择"""
	# 创建选择面板
	var choice_panel = Panel.new()
	choice_panel.anchors_preset = Control.PRESET_CENTER
	choice_panel.custom_minimum_size = Vector2(400, 200)
	choice_panel.position = Vector2(300, 250)
	
	# 设置面板样式
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.3, 0.3, 0.5)
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_left = 10
	style_box.corner_radius_bottom_right = 10
	choice_panel.add_theme_stylebox_override("panel", style_box)
	
	# 创建标题
	var title_label = Label.new()
	title_label.text = "选择下一步"
	title_label.anchors_preset = Control.PRESET_TOP_WIDE
	title_label.offset_left = 20
	title_label.offset_top = 20
	title_label.offset_right = -20
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# 创建按钮容器
	var button_container = VBoxContainer.new()
	button_container.anchors_preset = Control.PRESET_FULL_RECT
	button_container.offset_left = 20
	button_container.offset_top = 60
	button_container.offset_right = -20
	button_container.offset_bottom = -20
	button_container.add_theme_constant_override("separation", 10)
	
	# 继续剧情按钮
	var continue_button = Button.new()
	continue_button.text = "继续剧情"
	continue_button.custom_minimum_size = Vector2(0, 40)
	continue_button.add_theme_font_size_override("font_size", 16)
	continue_button.connect("pressed", _on_continue_story)
	
	# 结束对话按钮
	var end_button = Button.new()
	end_button.text = "结束对话"
	end_button.custom_minimum_size = Vector2(0, 40)
	end_button.add_theme_font_size_override("font_size", 16)
	end_button.connect("pressed", _on_end_dialogue)
	
	# 添加按钮到容器
	button_container.add_child(continue_button)
	button_container.add_child(end_button)
	
	# 添加组件到面板
	choice_panel.add_child(title_label)
	choice_panel.add_child(button_container)
	
	# 添加到场景
	add_child(choice_panel)

func _on_continue_story():
	"""继续剧情"""
	print("继续剧情...")
	
	# 移除选择面板
	for child in get_children():
		if child is Panel and child != free_dialogue_panel:
			child.queue_free()
	
	# 获取当前对话的选择项
	var dialogue_manager = get_parent().get_node("DialogueManager")
	var current_dialogue = dialogue_manager.current_dialogue
	
	if current_dialogue.has("choices"):
		# 显示选择项
		show_choices(current_dialogue["choices"])
	else:
		# 结束对话
		dialogue_manager.end_dialogue()

func _on_end_dialogue():
	"""结束对话"""
	print("结束对话...")
	
	# 移除选择面板
	for child in get_children():
		if child is Panel and child != free_dialogue_panel:
			child.queue_free()
	
	# 结束对话
	var dialogue_manager = get_parent().get_node("DialogueManager")
	dialogue_manager.end_dialogue()

func send_message(message: String):
	"""发送消息"""
	# 添加用户消息到界面
	add_user_message(message)
	
	# 清空输入框
	message_input.text = ""
	
	# 发送消息到AI
	var dialogue_manager = get_node("../DialogueManager")
	dialogue_manager.send_message_to_ai(message)
	
	# 发出信号
	message_sent.emit(message)

func show_ai_response(response: String):
	"""显示AI回复"""
	print("=== UI管理器显示AI回复开始 ===")
	print("收到的AI回复: ", response)
	print("回复长度: ", response.length())
	
	add_ai_message(response)
	
	print("=== UI管理器显示AI回复结束 ===")

func create_background():
	"""创建背景图片"""
	background_texture = TextureRect.new()
	background_texture.anchors_preset = Control.PRESET_FULL_RECT
	background_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	background_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	
	# 如果你有背景图片，可以在这里加载
	# var texture = load("res://assets/background.jpg")
	# background_texture.texture = texture
	
	# 暂时使用纯色背景
	background_texture.modulate = Color(0.2, 0.2, 0.3, 1.0)
	
	# 将背景添加到对话UI的最底层
	$DialogueUI.add_child(background_texture)
	$DialogueUI.move_child(background_texture, 0)  # 移到最底层

func show_dialogue(text: String):
	"""显示对话文本"""
	print("显示对话: ", text)
	dialogue_text.text = text
	dialogue_panel.show()
	
	# 播放打字机效果
	play_typewriter_effect(text)

func play_typewriter_effect(text: String):
	"""播放打字机效果"""
	dialogue_text.visible_characters = 0
	dialogue_text.text = text
	
	var tween = create_tween()
	tween.tween_method(set_visible_characters, 0, text.length(), 2.0)

func set_visible_characters(count: int):
	"""设置可见字符数"""
	dialogue_text.visible_characters = count

func show_choices(choices: Array):
	"""显示选择项"""
	print("显示选择项: ", choices.size(), " 个选项")
	
	# 清除之前的选择项
	for child in choice_container.get_children():
		child.queue_free()
	
	# 设置容器间距
	choice_container.add_theme_constant_override("separation", 10)
	
	# 创建新的选择按钮
	for choice in choices:
		var button = Button.new()
		button.text = choice["text"]
		button.custom_minimum_size = Vector2(0, 45)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
		# 设置按钮样式
		button.add_theme_font_size_override("font_size", 16)
		
		# 添加按钮
		choice_container.add_child(button)
		
		# 连接按钮信号
		button.pressed.connect(_on_choice_button_pressed.bind(choice["id"]))
		
		print("添加按钮: ", choice["text"])

func _on_choice_button_pressed(choice_id: String):
	"""处理选择按钮点击"""
	choice_selected.emit(choice_id)

func hide_dialogue():
	"""隐藏对话UI"""
	dialogue_panel.hide()
	
	# 清除选择项
	for child in choice_container.get_children():
		child.queue_free()

func toggle_inventory():
	"""切换物品栏显示"""
	if inventory_panel.visible:
		hide_inventory()
	else:
		show_inventory()

func show_inventory():
	"""显示物品栏"""
	inventory_panel.show()
	var game_manager = get_node("../GameManager")
	game_manager.change_state(game_manager.GameState.INVENTORY)
	update_inventory_display()

func hide_inventory():
	"""隐藏物品栏"""
	inventory_panel.hide()
	var game_manager = get_node("../GameManager")
	game_manager.change_state(game_manager.GameState.PLAYING)

func update_inventory_display():
	"""更新物品栏显示"""
	# 清除之前的物品显示
	for child in inventory_list.get_children():
		child.queue_free()
	
	# 显示当前物品
	var inventory_manager = get_node("../InventoryManager")
	var items = inventory_manager.get_all_items()
	for item_id in items:
		var item = items[item_id]
		var item_label = Label.new()
		item_label.text = item["name"] + " - " + item["description"]
		item_label.custom_minimum_size = Vector2(0, 30)
		inventory_list.add_child(item_label)

func show_message(message: String, duration: float = 3.0):
	"""显示临时消息"""
	var message_label = Label.new()
	message_label.text = message
	message_label.add_theme_font_size_override("font_size", 24)
	message_label.position = Vector2(400, 300)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	add_child(message_label)
	
	# 创建淡入淡出效果
	var tween = create_tween()
	tween.tween_property(message_label, "modulate:a", 1.0, 0.5)
	tween.tween_delay(duration)
	tween.tween_property(message_label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(message_label.queue_free)

func show_notification(text: String):
	"""显示通知"""
	print("通知: ", text)
	show_message(text, 2.0)

func create_time_display():
	"""创建时间显示"""
	time_label = Label.new()
	time_label.text = "08:00"
	time_label.add_theme_font_size_override("font_size", 24)
	time_label.position = Vector2(20, 20)
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	add_child(time_label)
	
	# 连接时间变化信号
	var dialogue_manager = get_node("../DialogueManager")
	dialogue_manager.connect("time_changed", _on_time_changed)

func _on_time_changed(new_time: String):
	"""时间变化时的回调"""
	time_label.text = new_time
	print("时间更新为: ", new_time)

func update_time_display(time_string: String):
	"""更新时间显示"""
	time_label.text = time_string

func load_background_image(image_path: String):
	"""加载背景图片"""
	if FileAccess.file_exists(image_path):
		var texture = load(image_path)
		if texture:
			background_texture.texture = texture
			print("背景图片加载成功: ", image_path)
		else:
			print("无法加载图片: ", image_path)
	else:
		print("图片文件不存在: ", image_path)

func set_background_color(color: Color):
	"""设置背景颜色"""
	background_texture.modulate = color

func show_end_summary(summary_text: String):
	"""显示游戏结束总结"""
	print("开始显示总结面板")
	
	# 隐藏对话UI
	hide_dialogue()
	
	# 创建总结面板
	var summary_panel = Panel.new()
	summary_panel.anchors_preset = Control.PRESET_CENTER
	summary_panel.custom_minimum_size = Vector2(800, 500)
	summary_panel.position = Vector2(200, 100)
	
	# 设置面板样式
	summary_panel.add_theme_stylebox_override("panel", create_panel_style())
	
	# 创建标题
	var title_label = Label.new()
	title_label.text = "=== 互联网牛马的一天总结 ==="
	title_label.anchors_preset = Control.PRESET_TOP_WIDE
	title_label.offset_left = 20
	title_label.offset_top = 20
	title_label.offset_right = -20
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# 创建总结文本
	var summary_label = RichTextLabel.new()
	summary_label.anchors_preset = Control.PRESET_FULL_RECT
	summary_label.offset_left = 20
	summary_label.offset_top = 60
	summary_label.offset_right = -20
	summary_label.offset_bottom = -100
	summary_label.bbcode_enabled = true
	summary_label.text = summary_text
	summary_label.add_theme_font_size_override("font_size", 16)
	summary_label.fit_content = true
	
	# 创建关闭按钮
	var close_button = Button.new()
	close_button.text = "关闭"
	close_button.anchors_preset = Control.PRESET_BOTTOM_WIDE
	close_button.offset_left = 350
	close_button.offset_bottom = -20
	close_button.offset_right = -350
	close_button.custom_minimum_size = Vector2(0, 40)
	close_button.add_theme_font_size_override("font_size", 16)
	close_button.connect("pressed", summary_panel.queue_free)
	
	# 添加组件到面板
	summary_panel.add_child(title_label)
	summary_panel.add_child(summary_label)
	summary_panel.add_child(close_button)
	
	# 添加到场景
	add_child(summary_panel)

func create_panel_style() -> StyleBoxFlat:
	"""创建面板样式"""
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.3, 0.3, 0.5)
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_left = 10
	style_box.corner_radius_bottom_right = 10
	return style_box 
