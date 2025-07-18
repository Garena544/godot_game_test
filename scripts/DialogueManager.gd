extends Node
class_name DialogueManager

# 对话管理器
# 负责处理游戏中的文字对话和选择

signal dialogue_started(dialogue_id)
signal dialogue_ended(dialogue_id)
signal choice_made(choice_id)
signal time_changed(new_time: String)

var current_dialogue: Dictionary = {}
var dialogue_queue: Array = []
var is_dialogue_active: bool = false
var current_dialogue_index: int = 0

# 时间系统
var current_time: int = 8  # 早上8点开始
var time_minutes: int = 0
var day_events: Array = []

# LM Studio 配置
var lm_studio_url: String = "http://127.0.0.1:1234/v1/chat/completions"
var conversation_history: Array = []
var current_context: String = ""
var llm_enabled: bool = false

# 对话数据 - 互联网牛马的一天
var dialogues: Dictionary = {
	"wake_up": {
		"text": "早上8:00，闹钟响了。\n\n你是一个互联网公司的程序员，今天又是充满挑战的一天。",
		"choices": [
			{"id": "get_up_early", "text": "立刻起床，精神饱满"},
			{"id": "snooze_alarm", "text": "再睡5分钟"},
			{"id": "check_phone", "text": "先看看手机消息"},
			{"id": "free_dialogue", "text": "开始自由对话"}
		],
		"has_npc_dialogue": false  # 这是场景描述，不是NPC对话
	},
	"get_up_early": {
		"text": "你精神饱满地起床了！\n\n洗漱完毕，准备出门。今天感觉状态不错。",
		"choices": [
			{"id": "take_bus", "text": "坐公交车去公司"},
			{"id": "take_subway", "text": "坐地铁去公司"},
			{"id": "order_breakfast", "text": "先点个早餐外卖"}
		],
		"has_npc_dialogue": false
	},
	"snooze_alarm": {
		"text": "你又睡了5分钟...\n\n现在8:15了，时间有点紧张。",
		"choices": [
			{"id": "rush_out", "text": "匆忙出门"},
			{"id": "skip_breakfast", "text": "不吃早餐直接去公司"},
			{"id": "call_taxi", "text": "叫个出租车"}
		],
		"has_npc_dialogue": false
	},
	"check_phone": {
		"text": "你拿起手机，发现老板在群里@了所有人：\n\n'今天有个紧急需求，大家早点到公司！'",
		"choices": [
			{"id": "rush_to_company", "text": "立刻出发去公司"},
			{"id": "reply_ok", "text": "回复'收到'然后准备"},
			{"id": "ignore_message", "text": "假装没看到"}
		],
		"has_npc_dialogue": true  # 这是老板的消息，需要NPC对话
	},
	"arrive_company": {
		"text": "9:00，你到达公司。\n\n同事小王正在咖啡机前排队，看起来有点疲惫。",
		"choices": [
			{"id": "greet_wang", "text": "和小王打招呼"},
			{"id": "go_desk", "text": "直接去工位"},
			{"id": "get_coffee", "text": "也去排队买咖啡"}
		],
		"has_npc_dialogue": false
	},
	"greet_wang": {
		"text": "'早啊小王！'你打招呼。\n\n'早...昨晚又加班到12点，这个bug太难搞了。'小王苦笑道。",
		"choices": [
			{"id": "help_wang", "text": "'要不要我帮你看看？'"},
			{"id": "sympathize", "text": "'辛苦了，互联网人都不容易'"},
			{"id": "focus_own_work", "text": "'我先去忙自己的事了'"}
		],
		"has_npc_dialogue": true  # 这是和小王的对话
	},
	"help_wang": {
		"text": "你决定帮助小王。\n\n经过半小时的调试，你们一起解决了这个bug。小王很感激。",
		"choices": [
			{"id": "continue_work", "text": "继续自己的工作"},
			{"id": "team_lunch", "text": "约小王一起吃午饭"}
		],
		"has_npc_dialogue": false
	},
	"morning_meeting": {
		"text": "10:00，晨会时间。\n\n产品经理小李正在讲解新功能需求，看起来又是一个'简单'的需求。",
		"choices": [
			{"id": "ask_questions", "text": "提出技术问题"},
			{"id": "accept_quietly", "text": "默默接受"},
			{"id": "suggest_timeline", "text": "建议合理的时间安排"}
		],
		"has_npc_dialogue": false
	},
	"ask_questions": {
		"text": "你提出了几个技术细节问题。\n\n小李有点不耐烦：'这个很简单，你们程序员总是想得太复杂。'",
		"choices": [
			{"id": "insist_details", "text": "坚持要详细讨论"},
			{"id": "compromise", "text": "妥协，先做出来看看"},
			{"id": "document_concerns", "text": "把问题记录下来"}
		],
		"has_npc_dialogue": true  # 这是和小李的对话
	},
	"lunch_time": {
		"text": "12:00，午饭时间。\n\n同事们都在讨论去哪里吃饭。",
		"choices": [
			{"id": "company_canteen", "text": "去公司食堂"},
			{"id": "order_delivery", "text": "点外卖"},
			{"id": "go_outside", "text": "出去吃"}
		],
		"has_npc_dialogue": false
	},
	"afternoon_work": {
		"text": "13:30，下午工作开始。\n\n你正在专注地写代码，突然测试小姐姐小红走了过来。",
		"choices": [
			{"id": "greet_hong", "text": "和小红打招呼"},
			{"id": "focus_coding", "text": "继续专注写代码"},
			{"id": "ask_test_status", "text": "询问测试进度"}
		],
		"has_npc_dialogue": false
	},
	"greet_hong": {
		"text": "'小红，有什么问题吗？'你问道。\n\n'你昨天提交的代码有个小问题，能帮我看看吗？'小红说。",
		"choices": [
			{"id": "help_hong", "text": "立刻帮她解决"},
			{"id": "schedule_later", "text": "约个时间稍后处理"},
			{"id": "explain_priority", "text": "解释当前工作优先级"}
		],
		"has_npc_dialogue": true  # 这是和小红的对话
	},
	"help_hong": {
		"text": "你花了一些时间帮小红解决了问题。\n\n她很感谢你的帮助，你们的关系更好了。",
		"choices": [
			{"id": "return_coding", "text": "回到自己的代码"},
			{"id": "chat_more", "text": "多聊几句"}
		],
		"has_npc_dialogue": false
	},
	"evening_work": {
		"text": "18:00，正常下班时间。\n\n但是你的代码还没写完，而且老板在群里问进度。",
		"choices": [
			{"id": "overtime_work", "text": "加班完成"},
			{"id": "go_home", "text": "按时下班"},
			{"id": "work_from_home", "text": "回家继续工作"}
		],
		"has_npc_dialogue": false
	},
	"overtime_work": {
		"text": "你决定加班完成工作。\n\n20:00，终于完成了今天的任务。虽然很累，但很有成就感。",
		"choices": [
			{"id": "go_home_happy", "text": "开心地回家"},
			{"id": "celebrate", "text": "和同事一起庆祝"}
		],
		"has_npc_dialogue": false
	},
	"go_home": {
		"text": "你按时下班了。\n\n虽然工作没完成，但你觉得工作生活平衡很重要。",
		"choices": [
			{"id": "evening_rest", "text": "晚上好好休息"},
			{"id": "plan_tomorrow", "text": "规划明天的工作"}
		],
		"has_npc_dialogue": false
	},
	"end_day": {
		"text": "一天结束了。\n\n作为互联网牛马，你今天经历了各种挑战和选择。明天又是新的一天！",
		"choices": [
			{"id": "restart_day", "text": "重新开始这一天"},
			{"id": "free_dialogue", "text": "开始自由对话"},
			{"id": "end_game", "text": "结束游戏"}
		],
		"has_npc_dialogue": false
	}
}

func _ready():
	# 等待一帧确保所有节点都已准备好
	await get_tree().process_frame
	
	# 连接UI信号
	var ui_manager = get_node("../UIManager")
	ui_manager.connect("choice_selected", _on_choice_selected)
	
	# 初始化时间
	update_time_display()
	
	# 初始化对话历史
	initialize_conversation()

func initialize_conversation():
	"""初始化对话历史"""
	conversation_history = []
	current_context = "你是一个互联网公司的程序员，正在经历一天的工作生活。请用自然、友好的语气与玩家对话。"

func enable_llm_dialogue():
	"""启用LLM对话"""
	llm_enabled = true
	print("LLM对话已启用")
	
	# 显示通知
	var ui_manager = get_node("../UIManager")
	ui_manager.show_notification("LLM对话已启用！")

func start_dialogue(dialogue_id: String):
	"""开始对话"""
	if dialogue_id in dialogues:
		current_dialogue = dialogues[dialogue_id]
		current_dialogue_index = 0
		is_dialogue_active = true
		
		# 改变游戏状态
		var game_manager = get_node("../GameManager")
		game_manager.change_state(game_manager.GameState.DIALOGUE)
		
		# 显示对话
		display_dialogue()
		
		dialogue_started.emit(dialogue_id)
		print("开始对话: ", dialogue_id)

func display_dialogue():
	"""显示当前对话"""
	if current_dialogue.has("text"):
		var ui_manager = get_node("../UIManager")
		
		# 检查是否有NPC对话
		if current_dialogue.has("has_npc_dialogue") and current_dialogue["has_npc_dialogue"]:
			# 有NPC对话，启动自由对话模式
			start_free_dialogue_with_context(current_dialogue["text"])
		else:
			# 没有NPC对话，使用预设对话
			ui_manager.show_dialogue(current_dialogue["text"])
			
			# 显示选择项
			if current_dialogue.has("choices"):
				ui_manager.show_choices(current_dialogue["choices"])

func generate_llm_dialogue(original_text: String):
	"""使用LLM生成对话"""
	print("使用LLM生成对话: ", original_text)
	
	# 构建提示词
	var prompt = "你是一个互联网公司的程序员。请基于以下场景生成一段自然的对话：\n\n"
	prompt += "场景：" + original_text + "\n\n"
	prompt += "请用第一人称的语气，自然地描述这个场景，并给出几个选择选项。"
	
	# 发送到LLM
	send_llm_prompt(prompt)

func send_llm_prompt(prompt: String):
	"""发送提示词到LLM"""
	print("发送提示词到LLM: ", prompt)
	
	# 构建请求数据
	var request_data = {
		"model": "local-model",
		"messages": [
			{"role": "system", "content": current_context},
			{"role": "user", "content": prompt}
		],
		"temperature": 0.7,
		"max_tokens": 300
	}
	
	# 发送HTTP请求
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", _on_llm_dialogue_received)
	
	var headers = ["Content-Type: application/json"]
	var json_string = JSON.stringify(request_data)
	
	var error = http_request.request(lm_studio_url, headers, HTTPClient.METHOD_POST, json_string)
	if error != OK:
		print("HTTP请求失败: ", error)
		# 如果AI不可用，使用预设对话
		fallback_to_preset_dialogue()

func _on_llm_dialogue_received(result, response_code, headers, body):
	"""处理LLM对话回复"""
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		
		if parse_result == OK:
			var response_data = json.data
			if response_data.has("choices") and response_data["choices"].size() > 0:
				var ai_message = response_data["choices"][0]["message"]["content"]
				
				# 显示AI生成的对话
				var ui_manager = get_node("../UIManager")
				ui_manager.show_dialogue(ai_message)
				
				# 显示选择项（使用预设的选择项）
				if current_dialogue.has("choices"):
					ui_manager.show_choices(current_dialogue["choices"])
				
				print("LLM生成的对话: ", ai_message)
			else:
				fallback_to_preset_dialogue()
		else:
			print("JSON解析失败")
			fallback_to_preset_dialogue()
	else:
		print("HTTP请求失败，状态码: ", response_code)
		fallback_to_preset_dialogue()

func fallback_to_preset_dialogue():
	"""回退到预设对话"""
	print("回退到预设对话")
	var ui_manager = get_node("../UIManager")
	ui_manager.show_dialogue(current_dialogue["text"])
	
	if current_dialogue.has("choices"):
		ui_manager.show_choices(current_dialogue["choices"])

func start_free_dialogue():
	"""开始自由对话模式"""
	is_dialogue_active = true
	
	# 改变游戏状态
	var game_manager = get_node("../GameManager")
	game_manager.change_state(game_manager.GameState.DIALOGUE)
	
	# 显示自由对话UI
	var ui_manager = get_node("../UIManager")
	ui_manager.show_free_dialogue()
	
	print("开始自由对话模式")

func start_free_dialogue_with_context(context: String):
	"""根据剧情上下文启动自由对话"""
	print("启动NPC对话，上下文：", context)
	
	# 根据剧情确定NPC角色
	var npc_role = get_npc_role_from_context(context)
	
	# 设置当前剧情上下文
	current_context = "你是一个互联网公司的程序员，正在与" + npc_role + "对话。当前剧情：" + context + "\n\n请以" + npc_role + "的身份，用自然、简洁的语气与玩家对话。直接回复，不要使用任何标签或格式。"
	
	# 清空对话历史
	conversation_history = []
	
	# 显示NPC对话UI
	var ui_manager = get_node("../UIManager")
	ui_manager.show_npc_dialogue_with_context(context)
	
	# 改变游戏状态
	var game_manager = get_node("../GameManager")
	game_manager.change_state(game_manager.GameState.DIALOGUE)
	
	is_dialogue_active = true
	print("NPC对话已启动")

func get_npc_role_from_context(context: String) -> String:
	"""根据剧情上下文确定NPC角色"""
	if "老板" in context or "群里" in context:
		return "老板"
	elif "小王" in context:
		return "同事小王"
	elif "小李" in context:
		return "产品经理小李"
	elif "小红" in context:
		return "测试小姐姐小红"
	else:
		return "同事"

func send_message_to_ai(user_message: String):
	"""发送消息到AI并获取回复"""
	print("发送消息到AI: ", user_message)
	
	# 添加用户消息到历史
	conversation_history.append({"role": "user", "content": user_message})
	
	# 构建请求数据
	var request_data = {
		"model": "local-model",  # LM Studio 本地模型
		"messages": [
			{"role": "system", "content": current_context}
		] + conversation_history,
		"temperature": 0.7,
		"max_tokens": 500  # 增加token限制
	}
	
	# 发送HTTP请求
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", _on_ai_response_received)
	
	var headers = ["Content-Type: application/json"]
	var json_string = JSON.stringify(request_data)
	
	var error = http_request.request(lm_studio_url, headers, HTTPClient.METHOD_POST, json_string)
	if error != OK:
		print("HTTP请求失败: ", error)
		# 如果AI不可用，显示默认回复
		show_default_response(user_message)

func _on_ai_response_received(result, response_code, headers, body):
	"""处理AI回复"""
	print("=== AI回复处理开始 ===")
	print("响应状态码: ", response_code)
	print("响应头: ", headers)
	print("响应体长度: ", body.size())
	
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		
		print("JSON解析结果: ", parse_result)
		
		if parse_result == OK:
			var response_data = json.data
			print("响应数据: ", response_data)
			
			if response_data.has("choices") and response_data["choices"].size() > 0:
				var ai_message = response_data["choices"][0]["message"]["content"]
				
				print("提取的AI消息: ", ai_message)
				print("AI消息长度: ", ai_message.length())
				
				# 清理AI回复内容
				ai_message = clean_ai_response(ai_message)
				
				print("清理后的AI消息: ", ai_message)
				
				# 添加AI回复到历史
				conversation_history.append({"role": "assistant", "content": ai_message})
				
				# 显示AI回复
				var ui_manager = get_node("../UIManager")
				print("调用UI管理器显示AI回复...")
				ui_manager.show_npc_ai_response(ai_message)
				
				print("AI回复处理完成")
			else:
				print("响应中没有choices或choices为空")
				show_default_response("")
		else:
			print("JSON解析失败")
			show_default_response("")
	else:
		print("HTTP请求失败，状态码: ", response_code)
		print("错误响应体: ", body.get_string_from_utf8())
		show_default_response("")
	
	print("=== AI回复处理结束 ===")

func clean_ai_response(response: String) -> String:
	"""清理AI回复内容"""
	var cleaned = response
	
	# 移除<think>标签及其内容
	var think_start = cleaned.find("<think>")
	if think_start != -1:
		var think_end = cleaned.find("</think>")
		if think_end != -1:
			cleaned = cleaned.substr(0, think_start) + cleaned.substr(think_end + 8)
		else:
			cleaned = cleaned.substr(0, think_start)
	
	# 移除其他可能的标签
	cleaned = cleaned.replace("<s>", "").replace("</s>", "")
	cleaned = cleaned.replace("<|im_start|>", "").replace("<|im_end|>", "")
	
	# 清理多余的空白字符
	cleaned = cleaned.strip_edges()
	
	# 如果清理后为空，返回默认回复
	if cleaned.is_empty():
		cleaned = "我理解你的意思，让我们继续对话吧。"
	
	return cleaned

func show_default_response(user_message: String):
	"""显示默认回复（当AI不可用时）"""
	var default_responses = [
		"我理解你的想法。",
		"这确实是个有趣的观点。",
		"让我们继续讨论这个话题。",
		"你说得很有道理。",
		"我需要时间思考一下。"
	]
	
	var random_response = default_responses[randi() % default_responses.size()]
	
	var ui_manager = get_node("../UIManager")
	ui_manager.show_npc_ai_response(random_response)
	
	print("显示默认回复: ", random_response)

func advance_time(minutes: int):
	"""推进时间"""
	time_minutes += minutes
	if time_minutes >= 60:
		current_time += time_minutes / 60
		time_minutes = time_minutes % 60
	
	update_time_display()
	
	# 检查是否到达游戏结束时间
	if current_time >= 22:
		start_dialogue("end_day")

func update_time_display():
	"""更新时间显示"""
	var time_string = "%02d:%02d" % [current_time, time_minutes]
	time_changed.emit(time_string)
	print("当前时间: ", time_string)

func continue_dialogue():
	"""继续对话"""
	if is_dialogue_active:
		# 如果有多个对话文本，继续下一个
		if current_dialogue.has("texts") and current_dialogue_index < current_dialogue["texts"].size() - 1:
			current_dialogue_index += 1
			display_dialogue()
		else:
			# 对话结束
			end_dialogue()

func end_dialogue():
	"""结束对话"""
	is_dialogue_active = false
	current_dialogue = {}
	
	# 改变游戏状态
	var game_manager = get_node("../GameManager")
	game_manager.change_state(game_manager.GameState.PLAYING)
	
	# 隐藏对话UI
	var ui_manager = get_node("../UIManager")
	ui_manager.hide_dialogue()
	
	dialogue_ended.emit("")

func _on_choice_selected(choice_id: String):
	"""处理选择"""
	print("玩家选择了: ", choice_id)
	choice_made.emit(choice_id)
	
	# 根据选择执行相应的动作
	match choice_id:
		"get_up_early":
			advance_time(15)
			start_dialogue("get_up_early")
		"snooze_alarm":
			advance_time(15)
			start_dialogue("snooze_alarm")
		"check_phone":
			advance_time(10)
			start_dialogue("check_phone")
		"take_bus", "take_subway":
			advance_time(60)
			start_dialogue("arrive_company")
		"order_breakfast":
			advance_time(30)
			start_dialogue("arrive_company")
		"rush_out", "skip_breakfast":
			advance_time(45)
			start_dialogue("arrive_company")
		"call_taxi":
			advance_time(30)
			start_dialogue("arrive_company")
		"rush_to_company":
			advance_time(45)
			start_dialogue("arrive_company")
		"reply_ok":
			advance_time(30)
			start_dialogue("arrive_company")
		"ignore_message":
			advance_time(60)
			start_dialogue("arrive_company")
		"greet_wang":
			start_dialogue("greet_wang")
		"go_desk":
			advance_time(30)
			start_dialogue("morning_meeting")
		"get_coffee":
			advance_time(15)
			start_dialogue("arrive_company")
		"help_wang":
			advance_time(30)
			start_dialogue("morning_meeting")
		"sympathize":
			advance_time(10)
			start_dialogue("morning_meeting")
		"focus_own_work":
			advance_time(30)
			start_dialogue("morning_meeting")
		"ask_questions":
			start_dialogue("ask_questions")
		"accept_quietly":
			advance_time(60)
			start_dialogue("lunch_time")
		"suggest_timeline":
			advance_time(90)
			start_dialogue("lunch_time")
		"insist_details":
			advance_time(120)
			start_dialogue("lunch_time")
		"compromise":
			advance_time(90)
			start_dialogue("lunch_time")
		"document_concerns":
			advance_time(60)
			start_dialogue("lunch_time")
		"company_canteen", "order_delivery", "go_outside":
			advance_time(90)
			start_dialogue("afternoon_work")
		"greet_hong":
			start_dialogue("greet_hong")
		"focus_coding":
			advance_time(120)
			start_dialogue("evening_work")
		"ask_test_status":
			advance_time(30)
			start_dialogue("afternoon_work")
		"help_hong":
			advance_time(45)
			start_dialogue("evening_work")
		"schedule_later":
			advance_time(30)
			start_dialogue("evening_work")
		"explain_priority":
			advance_time(15)
			start_dialogue("evening_work")
		"return_coding":
			advance_time(120)
			start_dialogue("evening_work")
		"chat_more":
			advance_time(30)
			start_dialogue("evening_work")
		"overtime_work":
			advance_time(120)
			start_dialogue("overtime_work")
		"go_home":
			advance_time(30)
			start_dialogue("go_home")
		"work_from_home":
			advance_time(60)
			start_dialogue("go_home")
		"go_home_happy":
			advance_time(60)
			start_dialogue("end_day")
		"celebrate":
			advance_time(90)
			start_dialogue("end_day")
		"evening_rest":
			advance_time(120)
			start_dialogue("end_day")
		"plan_tomorrow":
			advance_time(60)
			start_dialogue("end_day")
		"restart_day":
			# 重置时间
			current_time = 8
			time_minutes = 0
			day_events.clear()
			update_time_display()
			start_dialogue("wake_up")
		"end_game":
			# 游戏结束
			var game_manager = get_node("../GameManager")
			game_manager.end_game()
		"free_dialogue":
			# 开始自由对话
			start_free_dialogue()
		_:
			# 默认继续探索
			start_dialogue("wake_up")

func add_dialogue(dialogue_id: String, dialogue_data: Dictionary):
	"""添加新的对话"""
	dialogues[dialogue_id] = dialogue_data

func get_dialogue(dialogue_id: String) -> Dictionary:
	"""获取对话数据"""
	return dialogues.get(dialogue_id, {})

func get_current_time() -> String:
	"""获取当前时间字符串"""
	return "%02d:%02d" % [current_time, time_minutes]

func show_end_summary():
	"""显示游戏结束总结"""
	var summary_text = generate_day_summary()
	
	var ui_manager = get_node("../UIManager")
	ui_manager.show_end_summary(summary_text)

func generate_day_summary() -> String:
	"""生成一天的总结"""
	var summary = "=== 互联网牛马的一天总结 ===\n\n"
	
	# 根据时间生成不同的总结
	if current_time < 10:
		summary += "你起得很早，是个勤奋的程序员！\n"
	elif current_time < 12:
		summary += "你按时到达公司，开始了新的一天。\n"
	else:
		summary += "你度过了充实的一天。\n"
	
	# 添加时间信息
	summary += "今天的工作时间：从8:00到" + get_current_time() + "\n\n"
	
	# 根据事件生成个性化总结
	var event_count = day_events.size()
	if event_count > 0:
		summary += "今天发生的重要事件：\n"
		for event in day_events:
			summary += "• " + event + "\n"
		summary += "\n"
	
	# 根据最终时间给出建议
	if current_time >= 22:
		summary += "你工作到很晚，辛苦了！记得注意休息。\n"
	elif current_time >= 20:
		summary += "你加班了，但完成了任务，很有成就感！\n"
	elif current_time >= 18:
		summary += "你按时下班，保持了工作生活平衡。\n"
	else:
		summary += "今天结束得比较早，效率很高！\n"
	
	summary += "\n=== 游戏结束 ==="
	
	return summary 
