extends Node

# LM Studio 连接测试脚本

var test_url: String = "http://localhost:1234/v1/chat/completions"

func _ready():
	print("开始测试LM Studio连接...")
	test_lm_studio_connection()

func test_lm_studio_connection():
	"""测试LM Studio连接"""
	var request_data = {
		"model": "local-model",
		"messages": [
			{"role": "system", "content": "你是一个友好的AI助手。"},
			{"role": "user", "content": "你好，请简单回复一下。"}
		],
		"temperature": 0.7,
		"max_tokens": 50
	}
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", _on_test_response_received)
	
	var headers = ["Content-Type: application/json"]
	var json_string = JSON.stringify(request_data)
	
	print("发送测试请求到: ", test_url)
	var error = http_request.request(test_url, headers, HTTPClient.METHOD_POST, json_string)
	
	if error != OK:
		print("HTTP请求失败: ", error)
		print("请确保LM Studio正在运行并监听端口1234")

func _on_test_response_received(result, response_code, headers, body):
	"""处理测试响应"""
	print("响应状态码: ", response_code)
	
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		
		if parse_result == OK:
			var response_data = json.data
			if response_data.has("choices") and response_data["choices"].size() > 0:
				var ai_message = response_data["choices"][0]["message"]["content"]
				print("✅ LM Studio连接成功！")
				print("AI回复: ", ai_message)
			else:
				print("❌ 响应格式不正确")
		else:
			print("❌ JSON解析失败")
	else:
		print("❌ HTTP请求失败，状态码: ", response_code)
		print("请检查LM Studio是否正在运行")
		print("响应内容: ", body.get_string_from_utf8()) 