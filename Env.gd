extends Node
class_name Env
# 运行环境

var _variable = {} # 变量存储
var _import_namespace = {} # 导包命名空间
static var _global_fun = {} # 全局函数存储

var _error = false # 是否报错

var target = null # 目标对象 xx.
var _parent: Env = null
var err: Error
var config = {}

func _init(c: Callable=func(): , cfg: Dictionary={}) -> void:
	_variable = {}
	config = cfg
	if not cfg.is_empty():
		cfg.r_path = ProjectSettings.globalize_path(cfg.path)
		cfg.dir = cfg.r_path.substr(0, String(cfg.r_path).rfind("/"))
	c.call()

func set_parent(p: Env):
	_parent = p
	return self

func add_var(vname, val, g: bool=false):
	if g:
		Env._global_fun[vname] = val
		return
	if _variable.has(vname):
		return G.err.push(0, "Redefining variables ： " + vname)
	_variable[vname] = val

func set_var_force(vname, val, g: bool=false):
	if g:
		Env._global_fun[vname] = val
		return
	_variable[vname] = val

func set_var(vname, val, g: bool=false):
	if g:
		Env._global_fun[vname] = val
		return
	if _variable.has(vname):
		_variable[vname] = val
	else:
		G.err.push(0, "the variable '" + vname + "' is undefined")

func get_var(vname):
	if target is AST.ObjectValNode and target.properties.has(vname):
		return target.properties[vname]
	if _import_namespace.has(vname):
		return _import_namespace[vname]
	if Env._global_fun.has(vname):
		return Env._global_fun[vname]
	if _variable.has(vname):
		return _variable[vname]
	if _parent:
		return _parent.get_var(vname)
	G.err.push(0, "the variable '" + vname + "' is undefined")
	return G.Token.new(G.TokenType.nil, null)

func set_target(obj):
	target = obj
func del_target():
	target = null

# 融合环境
func mixin(e: Env):
	for i in e._variable:
		_variable[i] = e._variable[i]

func create_import(_name, val_import : Env):
	_import_namespace[_name] = val_import
func del_import(_name):
	if _import_namespace.has(_name):
		_import_namespace.erase(_name)

