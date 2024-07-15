extends Control
"""
简单实现一个脚本语言：Xlang
作者：徐然先生
主页：www.xiaoxustudio.top
github：https://github.com/xiaoxustudio

目前实现:
变量声明
函数声明和函数调用，支持return 返回值
IF 简单的条件判断
For 循环：用,号分割 var i=0,i<10,i++ | 遍历 key in obj | 遍历 key,value in obj
全局函数：
print:打印

递增运算符： ++、--、**
三元表达式： 1==2? true : false
目前实现的数据类型：number、string、boolean、Array、Object
匿名函数 var a = fn()
print("我是匿名函数")
end

导入其他文件 import "mod" | import "mod" as m

对象遍历
var a = {
a = "测试",
b = 124
}
for i in a then
print("对象迭代key：" + i)
print("对象迭代value：" + a[i])
end
"""


@onready var text_edit: CodeEdit = $Panel/TextEdit

var file_open = "res://main.xs"
var config = {
	path =  file_open,
}

func _ready() -> void:
	G.set_highLight(text_edit)

func _input(event: InputEvent) -> void:
	if event is InputEvent:
		if event.as_text() == "F5" and event.is_pressed():
			G.enable_run()
			var env = Env.new(func():,config)
			var ipt = Interpreter.new(text_edit.text,env)
			ipt.evals()
			G.lex.clear()
			#print(ipt) # 打印解释器
			#print(ps.body_out(bodys)) # 打印body ast
			#print(ps.tokens_out()) # 打印tokens





