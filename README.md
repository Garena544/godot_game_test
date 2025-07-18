# 互联网牛马的一天 - Godot文字冒险游戏

一个关于互联网程序员日常生活的文字冒险游戏。

## 跨平台开发设置

### 方法1：Git版本控制（推荐）

#### 在PC上设置：
```bash
# 初始化Git仓库
git init
git add .
git commit -m "Initial commit"

# 创建GitHub仓库后连接
git remote add origin https://github.com/你的用户名/你的仓库名.git
git branch -M main
git push -u origin main
```

#### 在Mac上设置：
```bash
# 克隆仓库
git clone https://github.com/你的用户名/你的仓库名.git
cd 你的仓库名
```

#### 工作流程：
- **PC上修改后**：`git add . && git commit -m "更新" && git push`
- **Mac上获取更新**：`git pull`
- **Mac上修改后**：`git add . && git commit -m "更新" && git push`

### 方法2：云存储同步

1. 将项目文件夹放在OneDrive/Google Drive/Dropbox同步目录
2. 两台电脑都安装相同的云存储客户端
3. 自动同步文件

### 方法3：VS Code远程开发

1. 在PC上安装VS Code
2. 安装"Remote - SSH"扩展
3. 配置SSH连接到Mac
4. 在VS Code中远程编辑Mac上的文件

## 项目结构

```
godot-game-/
├── project.godot          # Godot项目文件
├── scenes/
│   └── Main.tscn         # 主场景
├── scripts/
│   ├── Main.gd           # 主场景脚本
│   ├── GameManager.gd    # 游戏管理器
│   ├── DialogueManager.gd # 对话管理器
│   ├── UIManager.gd      # UI管理器
│   ├── InventoryManager.gd # 物品管理器
│   ├── SceneManager.gd   # 场景管理器
│   └── SaveManager.gd    # 存档管理器
├── .gitignore            # Git忽略文件
└── README.md             # 项目说明
```

## 游戏特色

- **时间系统**：真实的时间流动
- **多个NPC**：小王（同事）、小李（产品经理）、小红（测试）
- **真实场景**：起床、通勤、工作、会议、午饭、加班
- **多种结局**：根据选择有不同的工作体验
- **个性化总结**：游戏结束时显示一天的总结

## 操作说明

- **点击选择按钮**：进行游戏选择
- **按Enter键**：继续对话
- **按I键**：打开/关闭物品栏
- **按空格键**：继续对话

## 开发环境要求

- Godot Engine 4.4.1 或更高版本
- 支持的操作系统：Windows, macOS, Linux

## 注意事项

1. 确保两台电脑都安装了相同版本的Godot
2. 避免同时编辑同一个文件
3. 定期提交和推送代码
4. 在切换设备前先提交当前更改

## 故障排除

### 如果Git同步有问题：
```bash
# 检查状态
git status

# 查看远程仓库
git remote -v

# 强制推送（谨慎使用）
git push --force
```

### 如果Godot项目无法打开：
1. 确保Godot版本一致
2. 删除.godot文件夹重新导入
3. 检查project.godot文件是否完整

## 贡献

欢迎提交Issue和Pull Request来改进游戏！ 