# Xlang

基于 GDS 的解释型脚本语言

# 目前实现:

变量声明

函数声明和函数调用，支持 return 返回值
IF 简单的条件判断
For 循环：用,号分割 var i=0,i<10,i++ | 遍历 key in obj | 遍历 key,value in obj
全局函数：
print:打印

递增运算符： ++、--、\*\*
三元表达式： 1==2? true : false
目前实现的数据类型：number、string、boolean、Array、Object
匿名函数 var a = fn()
print("我是匿名函数")
end

导入其他文件 import "mod" | import "mod" as m

对象遍历

```
var a = {
a = "测试",
b = 124
}
for i in a then
print("对象迭代 key：" + i)
print("对象迭代 value：" + a[i])
end
```
