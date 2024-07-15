extends Node
class_name Interpreter
# 解释器

var stmts:Array = []
var env : Env
var out_err = true # 是否输出错误信息

func _init(bodys,e: Env = Env.new()) -> void:
	env = e
	# 如果是源代码，则生成AST后解释
	if typeof(bodys) == TYPE_STRING:
		var _ts = G.lex.tokenlize(bodys)
		var ps = Parser.new(_ts,self)
		bodys = ps.exec()
	# 否则就直接解释
	stmts = bodys
	setupGlobalFunc()
func stop_ipt():
	stmts = []
	env._err = true
func get_value(tk):
	if tk is AST.ObjectValNode:
		var _arr = {}
		for _iik in tk.properties:
			_arr[_iik] = get_value(tk.properties[_iik])
		return _arr
	else:
		return tk.value
func setupGlobalFunc():
	# 定义全局函数
	mk_func("print",func(args):
		var process_i = func (i):
			if i is G.Token:
				return i.value
			elif i is AST.ArrayValNode:
				var _n = []
				for _ik in i.properties:
					_n.push_back(get_value(_ik))
				return _n
			elif i is AST.ObjectValNode:
				var _n = {}
				for _ik in i.properties:
					_n[_ik] = get_value(i.properties[_ik])
				return _n
			elif i is AST.ASTNode:
				# 直接输出对象
				var _id = i.get_instance_id()
				return "<$%s %s>" % [i.NodeType.substr(0,i.NodeType.length() - 4),_id]
		
		if args.size() == 1:
			print(str(process_i.call(args)))
		else:
			var _text = ""
			for i in args:
				_text += str(process_i.call(i)) + " "
			print(_text.substr(0,_text.length() - 1))
		return mk_null(),true)
func mk_str(val):
	return G.Token.new(G.TokenType.string,val)
func mk_num(val):
	return  G.Token.new(G.TokenType.num,val)
func mk_func(_name, c , global : bool = false):
	env.add_var(_name,AST.FnValNode.new({
		name = mk_str(_name),
		caller = c,
	}),global)
func mk_null():
	return G.Token.new(G.TokenType.nil,null)
func mk_bool(val : bool = false):
	return G.Token.new(G.TokenType.boolean,val)
func convert2base(_val): # 将数据类型转换为G.Token
	if _val is G.Token:
		return _val
	else:
		if _val.NodeType == 'ArrayValNode':
			var _n = ""
			for _ik in _val.properties:
				_n+=str(get_value(_ik)) + ','
			return G.Token.new(G.TokenType.string,_n.substr(0,_n.length() - 1))
	# 其他的都是为0的值
	return G.Token.new(G.TokenType.num,0)
func get_ident(val):
	if val is G.Token:
		return val.value
	elif val is AST.IdentifierNode or val is AST.StringNode or val is AST.NumNode:
		return val.value.value
	else:
		return val
func eat_body():
	stmts.remove_at(0)
func evals():
	for i:AST.ASTNode in stmts:
		if G.is_can_run:
			var res = eval(i,env)
func eval(stmt,e) -> Variant:
	if stmt is G.Token:
		return stmt as G.Token
	if stmt == null:
		return mk_null()
	stmt = stmt as AST.ASTNode
	match stmt.NodeType:
		"IdentifierNode":
			return eval_ident(stmt,e)
		"StringNode":
			return eval_str(stmt,e)
		"NumNode":
			return eval_num(stmt,e)
		"BoolNode":
			return eval_bool(stmt,e)
		"AddNode":
			return eval_Add(stmt,e)
		"MdNode":
			return eval_Md(stmt,e)
		"AssignNode":
			return eval_Assign(stmt,e)
		"TernaryNode":
			return eval_Ternary(stmt,e)
		"CompareNode":
			return eval_Compare(stmt,e)
		"ObjectNode":
			return eval_Object(stmt,e)
		"ArrayNode":
			return eval_Array(stmt,e)
		"ArrayPropertyNode":
			return eval_ArrayProperty(stmt,e)
		"MemberNode":
			return eval_Member(stmt,e)
		"UpdateNode":
			return eval_update(stmt,e)
		"FnNode":
			return eval_fn_def(stmt,e)
		"IFNode":
			return eval_if(stmt,e)
		"ForNode":
			return eval_for(stmt,e)
		"CallNode":
			return eval_call(stmt,e)
		"ReturnNode":
			return eval_return(stmt,e)
		"AnonymousNode":
			return eval_anonymous(stmt,e)
		"VariableNode":
			return eval_variable(stmt,e)
		"ImportNode":
			return eval_import(stmt,e)
		"ImportASNode":
			return eval_importas(stmt,e)
		"TryCatchNode":
			return eval_trycatch(stmt,e)
		_:
			return G.Token.new(G.TokenType.nil,"null")
func eval_trycatch(nd : AST.TryCatchNode,e:Env):
	# 先将报错信息更改
	var _e = Env.new()
	_e.set_parent(e)
	var _ipt = Interpreter.new(nd.runBody,_e)
	_ipt.out_err = false
	_ipt.evals()
	if _e.err:
		for i in nd.errBody:
			eval(i,e)
	for i in nd.finallyBody:
			eval(i,e)
func eval_importas(nd : AST.ImportASNode,e:Env):
	var _index = 0
	for i in nd.path:
		var _path = eval(i,e)
		var _concat_path_fname = e.config.dir + "/" + _path.value
		if not _concat_path_fname.ends_with(".xs"):
			_concat_path_fname += ".xs"
		var _fa = FileAccess.open(_concat_path_fname,FileAccess.READ)
		if FileAccess.get_open_error() != OK:
			if not FileAccess.file_exists(_concat_path_fname):
				if out_err:
					G.err.push(0,"import file not exists : " + _concat_path_fname)
				stop_ipt()
			else:
				if out_err:
					G.err.push(0,"import file error : " + _concat_path_fname)
				stop_ipt()
			return mk_null()
		var _env = Env.new(func():,{path =(_path.value if _path.value.ends_with(".xs") else _path.value + ".xs") })
		var _ipt = Interpreter.new(_fa.get_as_text(true),_env) as Interpreter
		_ipt.evals()
		var _a = get_ident(nd.as_path[_index])
		e.create_import(_a,_env)
		_index +=1
	return mk_null()
func eval_import(nd : AST.ImportNode,e:Env):
	for i in nd.path:
		var _path = eval(i,e)
		var _concat_path_fname = e.config.dir + "/" + _path.value
		if not _concat_path_fname.ends_with(".xs"):
			_concat_path_fname += ".xs"
		var _fa = FileAccess.open(_concat_path_fname,FileAccess.READ)
		if FileAccess.get_open_error() != OK:
			if not FileAccess.file_exists(_concat_path_fname):
				if out_err:
					G.err.push(0,"import file not exists : " + _concat_path_fname)
				stop_ipt()
			else:
				if out_err:
					G.err.push(0,"import file error : " + _concat_path_fname)
				stop_ipt()
			return mk_null()
		var _env = Env.new(func():,{path =(_path.value if _path.value.ends_with(".xs") else _path.value + ".xs") })
		var _ipt = Interpreter.new(_fa.get_as_text(true),_env) as Interpreter
		_ipt.evals()
		e.mixin(_env)
	return mk_null()
func eval_variable(nd : AST.VariableNode,e:Env):
	e.add_var(get_ident(nd.name),eval(nd.value,e))
	return G.Token.new(G.TokenType.nil,"null")
func eval_fn_def(nd : AST.FnNode,e:Env):
	e.add_var(get_ident(nd.name), nd )
	return G.Token.new(G.TokenType.nil,"null")
func eval_if(nd : AST.IFNode,e:Env):
	var condition = eval(nd.contidion,e)
	var _res = mk_null()
	if condition.value == true:
		for i : AST.ASTNode in nd.body:
			_res = eval(i,e)
			if i is AST.ReturnNode:
				break
		return _res
	elif nd.is_else:
		for i : AST.ASTNode in nd.else_body:
			_res = eval(i,e)
			if i is AST.ReturnNode:
				break
		return _res
func eval_for(nd : AST.ForNode,e:Env):
	var _env = Env.new()
	_env.set_parent(e)
	var is_iterate = nd.is_iterate
	if is_iterate:
		var left = get_ident(nd.left)
		var mid = get_ident(nd.mid)
		_env.add_var(left,null)
		if mid!=null: _env.add_var(mid,null)
		var right = eval(nd.right,_env)
		for _i in range(right.properties.size()):
			if right is AST.ObjectValNode:
				var _keys = right.properties.keys()
				var _val = right.properties[_keys[_i]]
				if mid!=null:
					_env.set_var_force(left,_keys[_i])
					_env.set_var_force(mid,_val)
				else:
					_env.set_var_force(left,_val)
				for i : AST.ASTNode in nd.body:
					eval(i,_env)
			else:
				_env.set_var_force(left,mk_num(_i))
				for i : AST.ASTNode in nd.body:
					eval(i,_env)
	else:
		var left = eval(nd.left,_env)
		while true:
			if eval(nd.mid,_env).value:
				for i : AST.ASTNode in nd.body:
					eval(i,_env)
				eval(nd.right,_env)
			else:
				break
func eval_return(nd : AST.ReturnNode,e:Env):
	return nd
func eval_call(nd : AST.CallNode,e:Env):
	var _name = nd.name
	var _res
	if _name is AST.AnonymousNode:
		_res = eval(_name,e)
	else:
		_res = e.get_var(get_ident(_name))
	# 调用内部函数
	if _res and _res is AST.FnValNode:
		if _res.caller is Callable:
			var args = nd.args.map(func(val): return eval(val,e))
			return _res.caller.call(args)
	# 调用自定义函数
	if _res and _res is AST.FnNode:
		var _rs = mk_null()
		var _e = Env.new().set_parent(e)
		var _args = nd.args.map(func(val): return eval(val,_e))
		for i in range(_args.size()):
			var _vname = _res.args[i]
			if _vname is AST.IdentifierNode:
				_e.add_var(get_ident(_res.args[i]),_args[i])
		for i : AST.ASTNode in _res.body:
			_rs = eval(i,_e)
			if _rs or i is AST.ReturnNode:
				if _rs is G.Token and _rs.type != G.TokenType.nil:
					break
				elif _rs is G.Token and _rs.type == G.TokenType.nil:
					continue
				else:
					break
		return eval(_rs.value,_e)
	# 调用匿名函数
	if _res is AST.AnonymousValNode:
		var _rs = mk_null()
		var _e = Env.new()
		_e.set_parent(e)
		var _args = nd.args.map(func(val): return eval(val,_e))
		for i in range(_args.size()):
			var _vname = _res.args[i]
			if _vname is AST.IdentifierNode:
				_e.add_var(get_ident(_res.args[i]),_args[i])
		for i : AST.ASTNode in _res.body:
			_rs = eval(i,_e)
			if _rs or i is AST.ReturnNode:
				if _rs is G.Token and _rs.type != G.TokenType.nil:
					break
				elif _rs is G.Token and _rs.type == G.TokenType.nil:
					continue
				else:
					break
		return eval(_rs.value,_e)
	return G.Token.new(G.TokenType.nil,"null")
func eval_anonymous(nd : AST.AnonymousNode,e:Env):
	return AST.AnonymousValNode.new({
		body = nd.body,
		args = nd.args
	})
func eval_bool(nd : AST.BoolNode,_e:Env):
	return G.Token.new(G.TokenType.boolean,nd.value.value)
func eval_num(nd : AST.NumNode,_e:Env):
	return G.Token.new(G.TokenType.num,nd.value.value)
func eval_str(nd : AST.StringNode,_e:Env):
	return G.Token.new(G.TokenType.string,nd.value.value)
func eval_ident(nd : AST.IdentifierNode,e:Env):
	var _res = e.get_var(get_ident(nd))
	return _res
func eval_Add(nd : AST.AddNode,e:Env):
	# 可能两边处理的数据不是同一个类型
	# 我们需要进行处理，使其能够正常运行
	# 将左右两侧都转成可以运算的数据类型
	var left = eval(nd.left,e)
	left = convert2base(left if left is G.Token else G.Token.new(G.TokenType.identifier,left))
	var op : G.Token = eval(nd.operate,e)
	var right  = convert2base(eval(nd.right,e))
	if op.value == "+":
		if left.type == G.TokenType.num and right.type == G.TokenType.num:
			return G.Token.new(G.TokenType.num,float(left.value) + float(right.value))
		else:
			return G.Token.new(G.TokenType.string,str(left.value) + str(right.value))
	if op.value == "-":
		if left.type == G.TokenType.num and right.type == G.TokenType.num:
			return G.Token.new(G.TokenType.num,float(left.value) - float(right.value))
	var _err = "connot runtime"
	if out_err:
		G.err.push(0 , _err)
	stop_ipt()
	assert(false,_err)
func eval_Md(nd : AST.MdNode,e:Env):
	var left : G.Token = eval(nd.left,e)
	left = left if left is G.Token else G.Token.new(G.TokenType.identifier,left)
	var op : G.Token = eval(nd.operate,e)
	var right : G.Token = eval(nd.right,e)
	if op.value == "*" and left.type == G.TokenType.num and right.type == G.TokenType.num:
		return G.Token.new(G.TokenType.num,float(left.value) * float(right.value))
	if op.value == "/" and left.type == G.TokenType.num and right.type == G.TokenType.num:
		return G.Token.new(G.TokenType.num,float(left.value) / float(right.value))
	var _err = "connot runtime"
	if out_err:
		G.err.push(0 , _err)
	stop_ipt()
	assert(false,_err)
func eval_Assign(nd : AST.AssignNode,e:Env):
	var value : G.Token = eval(nd.value,e)
	return env.set_var(get_ident(nd.left),value)
func eval_Ternary(nd : AST.TernaryNode,e:Env):
	var condition = eval(nd.contidion,e)
	var _res = null
	if condition.value == true:
		for i : AST.ASTNode in nd.body:
			_res = eval(i,e)
	else:
		for i : AST.ASTNode in nd.else_body:
			_res = eval(i,e)
	return _res
func eval_Compare(nd : AST.CompareNode,e:Env):
	var left : G.Token = eval(nd.left,e)
	var op : G.Token = eval(nd.operate,e)
	var right : G.Token = eval(nd.right,e)
	if op.value == "==" and left.value == right.value:
		return mk_bool(true)
	elif op.value == "!=" and left.value != right.value:
		return mk_bool(true)
	if not G.is_num(str(left.value)):
		assert(false,"variable " + str(left.value) + " is undefined")
		return mk_null()
	elif op.value == ">=" and float(left.value) >= float(right.value):
		return mk_bool(true)
	elif op.value == "<=" and float(left.value) <= float(right.value):
		return mk_bool(true)
	elif op.value == ">" and float(left.value) > float(right.value):
		return mk_bool(true)
	elif op.value == "<" and float(left.value) < float(right.value):
		return mk_bool(true)
	else:
		if op.type == G.TokenType.double_bo or [">","<"].find(op.value) != -1:
			return mk_bool(false)
		else:
			var _err = "connot identify the compare token " + op.value
			if out_err:
				G.err.push(0 , _err)
			stop_ipt()
			assert(false,_err)
func eval_Object(nd : AST.ObjectNode,e:Env):
	var _properties = {}
	for i : AST.ObjectPropertyNode in nd.properties:
		_properties[get_ident(i.key)] = eval(i.value,e)
	return AST.ObjectValNode.new({properties = _properties})
func eval_Array(nd : AST.ArrayNode,e:Env):
	var _properties = nd.properties
	var _arr = []
	for i : AST.ArrayPropertyNode in _properties:
		var _val = eval(i.value,e)
		if _val is AST.ArrayValNode:
			_val = _val
		elif _val is AST.ObjectValNode:
			_val = _val
		elif _val.type == G.TokenType.num:
			_val = mk_num(float(_val.value))
		elif _val.type == G.TokenType.string:
			_val = mk_str(str(_val.value))
		elif _val.type == G.TokenType.boolean:
			_val = mk_bool(true if _val.value == "true" else false)
		_arr.push_back(_val)
	return AST.ArrayValNode.new({
		properties = _arr
	})
func eval_Member(nd : AST.MemberNode,e:Env):
	var _obj  = eval(nd.object,e)
	if _obj is Env:
		return eval(nd.property,_obj)
	elif _obj is AST.ArrayNode:
		var _right = eval(nd.property,e)
		return _obj.properties[int(_right.value)]
	elif _obj is AST.ObjectValNode:
		var _env_target = Env.new()
		_env_target.set_target(_obj)
		var _right = eval(nd.property,_env_target)
		return _right
	return mk_null()
func eval_ArrayProperty(nd : AST.ArrayPropertyNode,e:Env):
	var _index = nd.index
	var _value = eval(nd.value,e)
	return _value
func eval_update(nd : AST.UpdateNode,e:Env):
	var left : G.Token = eval(nd.name,e)
	var op : G.Token = nd.operate
	var is_left : bool = nd.is_left
	if not G.is_num(str(left.value)):
		stop_ipt()
		assert(false,"variable " + str(left.value) + " is undefined")
		return mk_null()
	if op.value == "++":
		var _old = left.value
		var _val_after = float(left.value) + float(1)
		left.value = _val_after
		e.add_var(get_ident(left),left)
		return G.Token.new(G.TokenType.num,float(_val_after)) if is_left else G.Token.new(G.TokenType.num,float(_old))
	elif op.value == "--":
		var _old = left.value
		var _val_after = float(left.value) - float(1)
		left.value = _val_after
		e.add_var(get_ident(left),left)
		return G.Token.new(G.TokenType.num,float(_val_after)) if is_left else G.Token.new(G.TokenType.num,float(_old))
	elif op.value == "**":
		var _old = left.value
		var _val_after = float(left.value) * float(left.value)
		left.value = _val_after
		e.add_var(get_ident(left),left)
		return G.Token.new(G.TokenType.num,float(_val_after)) if is_left else G.Token.new(G.TokenType.num,float(_old))
	var _err = "connot runtime"
	if out_err:
		G.err.push(0 , _err)
	stop_ipt()
	assert(false,_err)
