extends CanvasLayer
class_name UIManager

# UI管理器
# 负责管理游戏的所有用户界面

signal choice_selected(choice_id)

var dialogue_panel: Panel
var dialogue_text: RichTextLabel
var choice_container: VBoxContainer
var inventory_panel: Panel
var inventory_list: VBoxContainer
var time_label: Label
var background_texture: TextureRect

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
	
	# 初始隐藏物品栏，但保持对话UI可见
	hide_inventory()
	
	print("UIManager 初始化完成")

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
	
	# 创建按钮容器
	var button_container = HBoxContainer.new()
	button_container.anchors_preset = Control.PRESET_BOTTOM_WIDE
	button_container.offset_left = 20
	button_container.offset_right = -20
	button_container.offset_bottom = -20
	button_container.add_theme_constant_override("separation", 20)
	
	# 创建重新开始按钮
	var restart_button = Button.new()
	restart_button.text = "重新开始"
	restart_button.custom_minimum_size = Vector2(150, 50)
	restart_button.add_theme_font_size_override("font_size", 18)
	restart_button.pressed.connect(_on_restart_button_pressed)
	
	# 创建退出按钮
	var quit_button = Button.new()
	quit_button.text = "退出游戏"
	quit_button.custom_minimum_size = Vector2(150, 50)
	quit_button.add_theme_font_size_override("font_size", 18)
	quit_button.pressed.connect(_on_quit_button_pressed)
	
	# 添加按钮到容器
	button_container.add_child(restart_button)
	button_container.add_child(quit_button)
	
	# 添加所有元素到总结面板
	summary_panel.add_child(title_label)
	summary_panel.add_child(summary_label)
	summary_panel.add_child(button_container)
	
	# 将总结面板添加到UI的最顶层
	add_child(summary_panel)
	summary_panel.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	
	print("总结面板已创建，文本长度: ", summary_text.length())

func create_panel_style() -> StyleBoxFlat:
	"""创建面板样式"""
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.3, 0.4, 1.0)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	return style

func _on_restart_button_pressed():
	"""重新开始游戏"""
	print("重新开始游戏")
	# 重新加载场景
	get_tree().reload_current_scene()

func _on_quit_button_pressed():
	"""退出游戏"""
	print("退出游戏")
	get_tree().quit() 
