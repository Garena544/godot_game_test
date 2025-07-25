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

# 独立对话框组件
var npc_dialogue_panel: Panel
var npc_dialogue_text: RichTextLabel
var npc_input_container: HBoxContainer
var npc_message_input: LineEdit
var npc_send_button: Button
var npc_back_button: Button

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
	
	# 创建独立NPC对话框
	create_npc_dialogue_ui()
	
	# 初始隐藏物品栏，但保持对话UI可见
	hide_inventory()
	
	print("UIManager 初始化完成")

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

func create_npc_dialogue_ui():
	"""创建独立NPC对话框"""
	print("创建独立NPC对话框")
	
	# 创建NPC对话面板 - 作为主对话面板的子组件
	npc_dialogue_panel = Panel.new()
	# 使用相对于主对话面板的位置，确保不遮挡输入框
	npc_dialogue_panel.position = Vector2(20, 20)
	npc_dialogue_panel.custom_minimum_size = Vector2(600, 300)  # 减小高度，避免遮挡
	npc_dialogue_panel.visible = false
	npc_dialogue_panel.z_index = 10  # 比主对话面板高，但比测试面板低
	
	print("NPC对话面板基础属性设置完成")
	print("面板位置: ", npc_dialogue_panel.position)
	print("面板尺寸: ", npc_dialogue_panel.size)
	print("面板最小尺寸: ", npc_dialogue_panel.custom_minimum_size)
	print("面板层级: ", npc_dialogue_panel.z_index)
	
	# 设置面板样式 - 使用更明显的背景色
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.1, 0.1, 0.2, 0.98)  # 更明显的背景色
	style_box.border_width_left = 5
	style_box.border_width_right = 5
	style_box.border_width_top = 5
	style_box.border_width_bottom = 5
	style_box.border_color = Color(0.6, 0.6, 0.8)  # 更明显的边框色
	style_box.corner_radius_top_left = 15
	style_box.corner_radius_top_right = 15
	style_box.corner_radius_bottom_left = 15
	style_box.corner_radius_bottom_right = 15
	npc_dialogue_panel.add_theme_stylebox_override("panel", style_box)
	
	print("NPC对话面板创建完成，背景色: ", style_box.bg_color)
	
	# 创建标题
	var title_label = Label.new()
	title_label.text = "NPC对话"
	title_label.position = Vector2(20, 20)
	title_label.size = Vector2(560, 30)
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.modulate = Color(1.0, 1.0, 0.8)
	
	print("标题标签创建完成")
	
	# 创建对话文本区域 - 减小高度
	npc_dialogue_text = RichTextLabel.new()
	npc_dialogue_text.position = Vector2(20, 60)
	npc_dialogue_text.size = Vector2(560, 150)  # 减小高度
	npc_dialogue_text.bbcode_enabled = true
	npc_dialogue_text.add_theme_font_size_override("font_size", 16)
	npc_dialogue_text.fit_content = true
	npc_dialogue_text.scroll_following = true
	npc_dialogue_text.scroll_active = true
	
	# 设置文本区域的背景色
	var text_style = StyleBoxFlat.new()
	text_style.bg_color = Color(0.05, 0.05, 0.1, 0.9)
	text_style.border_width_left = 2
	text_style.border_width_right = 2
	text_style.border_width_top = 2
	text_style.border_width_bottom = 2
	text_style.border_color = Color(0.3, 0.3, 0.5)
	text_style.corner_radius_top_left = 8
	text_style.corner_radius_top_right = 8
	text_style.corner_radius_bottom_left = 8
	text_style.corner_radius_bottom_right = 8
	npc_dialogue_text.add_theme_stylebox_override("normal", text_style)
	
	print("NPC对话文本区域创建完成")
	print("文本区域位置: ", npc_dialogue_text.position)
	print("文本区域尺寸: ", npc_dialogue_text.size)
	
	# 创建输入区域 - 调整位置
	npc_input_container = HBoxContainer.new()
	npc_input_container.position = Vector2(20, 230)  # 调整位置
	npc_input_container.size = Vector2(560, 50)
	npc_input_container.add_theme_constant_override("separation", 10)
	
	# 创建输入框
	npc_message_input = LineEdit.new()
	npc_message_input.placeholder_text = "输入你的消息..."
	npc_message_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	npc_message_input.add_theme_font_size_override("font_size", 16)
	npc_message_input.connect("text_submitted", _on_npc_message_submitted)
	
	# 创建发送按钮
	npc_send_button = Button.new()
	npc_send_button.text = "发送"
	npc_send_button.custom_minimum_size = Vector2(80, 40)
	npc_send_button.add_theme_font_size_override("font_size", 16)
	npc_send_button.connect("pressed", _on_npc_send_button_pressed)
	
	# 创建返回按钮
	npc_back_button = Button.new()
	npc_back_button.text = "返回"
	npc_back_button.custom_minimum_size = Vector2(80, 40)
	npc_back_button.add_theme_font_size_override("font_size", 16)
	npc_back_button.connect("pressed", _on_npc_back_button_pressed)
	
	# 添加组件到输入容器
	npc_input_container.add_child(npc_message_input)
	npc_input_container.add_child(npc_send_button)
	npc_input_container.add_child(npc_back_button)
	
	print("输入区域创建完成")
	
	# 添加所有组件到面板
	npc_dialogue_panel.add_child(title_label)
	print("标题标签已添加到面板")
	npc_dialogue_panel.add_child(npc_dialogue_text)
	print("文本区域已添加到面板")
	npc_dialogue_panel.add_child(npc_input_container)
	print("输入区域已添加到面板")
	
	# 添加到主对话面板，而不是直接添加到场景
	dialogue_panel.add_child(npc_dialogue_panel)
	print("NPC对话面板已添加到主对话面板")
	print("面板子节点数量: ", npc_dialogue_panel.get_child_count())
	
	print("独立NPC对话框创建完成")

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

func show_npc_dialogue_with_context(context: String):
	"""显示NPC对话界面"""
	print("显示NPC对话界面，上下文：", context)
	
	# 检查NPC对话文本对象是否存在
	if npc_dialogue_text == null:
		print("错误：npc_dialogue_text对象为空，重新创建NPC对话UI")
		create_npc_dialogue_ui()
	
	# 不隐藏主对话界面，而是嵌入到其中
	# hide_dialogue()  # 注释掉这行
	
	# 隐藏主对话面板的选择按钮，避免遮挡输入框
	if choice_container != null:
		choice_container.hide()
		print("隐藏主对话选择按钮")
	
	# 创建测试面板
	var test_panel = create_test_panel()
	
	# 清空对话文本
	if npc_dialogue_text != null:
		npc_dialogue_text.text = ""
		print("清空NPC对话文本成功")
		
		# 添加测试文本，确保面板可见
		npc_dialogue_text.text = "[color=red]测试：NPC对话面板已显示[/color]\n\n"
		print("添加测试文本到NPC对话面板")
		
		# 添加剧情背景
		add_npc_context_message(context)
		
		# 显示NPC对话面板
		npc_dialogue_panel.show()
		print("NPC对话面板显示状态: ", npc_dialogue_panel.visible)
		print("NPC对话面板位置: ", npc_dialogue_panel.position)
		print("NPC对话面板尺寸: ", npc_dialogue_panel.size)
		print("NPC对话面板层级: ", npc_dialogue_panel.z_index)
		print("NPC对话文本内容: ", npc_dialogue_text.text)
		print("NPC对话面板子节点数量: ", npc_dialogue_panel.get_child_count())
		
		# 检查所有子节点的可见性
		for i in range(npc_dialogue_panel.get_child_count()):
			var child = npc_dialogue_panel.get_child(i)
			print("子节点 ", i, " 类型: ", child.get_class(), " 可见性: ", child.visible)
		
		npc_message_input.grab_focus()
		
		# 确保面板在最前面 - 使用move_to_front()而不是raise()
		npc_dialogue_panel.move_to_front()
		
		# 强制更新面板
		npc_dialogue_panel.queue_redraw()
		
		print("NPC对话界面已显示")
		
		# 3秒后移除测试面板
		await get_tree().create_timer(3.0).timeout
		test_panel.queue_free()
		print("测试面板已移除")
	else:
		print("错误：无法创建NPC对话文本对象")

func add_npc_context_message(context: String):
	"""添加NPC对话的剧情背景"""
	if npc_dialogue_text != null:
		var context_text = "[color=yellow]剧情背景: " + context + "[/color]\n\n"
		npc_dialogue_text.text += context_text
	else:
		print("错误：npc_dialogue_text为空，无法添加剧情背景")

func add_npc_user_message(message: String):
	"""添加用户消息到NPC对话"""
	if npc_dialogue_text != null:
		var user_text = "[color=cyan]你: " + message + "[/color]\n\n"
		npc_dialogue_text.text += user_text
		print("添加用户消息到NPC对话: ", message)
	else:
		print("错误：npc_dialogue_text为空，无法添加用户消息")

func add_npc_ai_message(message: String):
	"""添加AI回复到NPC对话"""
	if npc_dialogue_text != null:
		var ai_text = "[color=orange]NPC: " + message + "[/color]\n\n"
		npc_dialogue_text.text += ai_text
		print("添加AI回复到NPC对话: ", message)
		
		# 确保文本区域滚动到底部
		await get_tree().process_frame
		npc_dialogue_text.scroll_to_line(npc_dialogue_text.get_line_count() - 1)
	else:
		print("错误：npc_dialogue_text为空，无法添加AI回复")

func hide_npc_dialogue():
	"""隐藏NPC对话界面"""
	npc_dialogue_panel.hide()
	print("隐藏NPC对话界面")
	
	# 重新显示主对话面板的选择按钮
	if choice_container != null:
		choice_container.show()
		print("重新显示主对话选择按钮")
	
	# 不需要重新显示主对话界面，因为它一直都在
	# 只需要确保主对话面板是可见的
	if dialogue_panel != null:
		dialogue_panel.show()
		print("主对话面板保持可见")
	else:
		print("错误：主对话面板为空")

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

func show_npc_ai_response(response: String):
	"""显示NPC对话的AI回复"""
	print("显示NPC对话AI回复: ", response)
	
	if npc_dialogue_panel != null:
		print("NPC对话面板可见性: ", npc_dialogue_panel.visible)
	else:
		print("错误：npc_dialogue_panel为空")
	
	if npc_dialogue_text != null:
		print("NPC对话文本内容长度: ", npc_dialogue_text.text.length())
	else:
		print("错误：npc_dialogue_text为空")
	
	add_npc_ai_message(response)
	
	if npc_dialogue_text != null:
		print("AI回复添加完成，当前文本长度: ", npc_dialogue_text.text.length())
	else:
		print("错误：npc_dialogue_text为空，无法获取文本长度")
	
	if npc_dialogue_panel != null:
		print("NPC对话面板仍然可见: ", npc_dialogue_panel.visible)
	else:
		print("错误：npc_dialogue_panel为空")

func _on_npc_message_submitted(text: String):
	"""处理NPC对话消息提交"""
	if text.strip_edges() != "":
		send_npc_message(text)

func _on_npc_send_button_pressed():
	"""处理NPC对话发送按钮点击"""
	var text = npc_message_input.text.strip_edges()
	if text != "":
		send_npc_message(text)

func _on_npc_back_button_pressed():
	"""处理NPC对话返回按钮点击"""
	hide_npc_dialogue()
	
	# 显示剧情选择
	show_story_choices()

func send_npc_message(message: String):
	"""发送NPC对话消息"""
	print("发送NPC对话消息: ", message)
	
	# 添加用户消息到界面
	add_npc_user_message(message)
	
	# 清空输入框
	npc_message_input.text = ""
	
	# 发送消息到AI
	var dialogue_manager = get_parent().get_node("DialogueManager")
	dialogue_manager.send_message_to_ai(message)
	
	# 发出信号
	message_sent.emit(message)

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

func create_test_panel():
	"""创建测试面板来验证显示功能"""
	print("创建测试面板...")
	
	# 创建一个简单的测试面板
	var test_panel = Panel.new()
	test_panel.anchors_preset = Control.PRESET_CENTER
	test_panel.custom_minimum_size = Vector2(400, 300)
	test_panel.position = Vector2(200, 150)
	test_panel.z_index = 1000  # 确保在最前面
	
	# 设置明显的背景色
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(1.0, 0.0, 0.0, 0.9)  # 红色背景
	style_box.border_width_left = 5
	style_box.border_width_right = 5
	style_box.border_width_top = 5
	style_box.border_width_bottom = 5
	style_box.border_color = Color(1.0, 1.0, 1.0)  # 白色边框
	test_panel.add_theme_stylebox_override("panel", style_box)
	
	# 创建测试标签
	var test_label = Label.new()
	test_label.text = "测试面板 - 如果你能看到这个，说明面板显示功能正常"
	test_label.anchors_preset = Control.PRESET_CENTER
	test_label.add_theme_font_size_override("font_size", 18)
	test_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	test_label.modulate = Color(1.0, 1.0, 1.0)
	
	# 添加组件到面板
	test_panel.add_child(test_label)
	
	# 添加到场景
	add_child(test_panel)
	
	print("测试面板已创建")
	return test_panel 
