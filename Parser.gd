extends Node
class_name Parser
# 解析器
var tokens = []
var err : Error = G.err
var _ipt : Interpreter
var out_err:bool 

# 前一个字符
var _s : G.Token

func _init(tk,_self : Interpreter) -> void:
	tokens = tk
	_ipt = _self
	out_err = _ipt.out_err
func stop_parse():
	tokens = [G.Token.new(G.TokenType.EOF,"EOF")]
	_ipt.env._error = true
func get_ident(val):
	if val is G.Token:
		return val.value
	elif val is AST.IdentifierNode or val is AST.StringNode or val is AST.NumNode:
		return val.value.value
	else:
		return val
func is_keywords(_str : String):
	if G.KEYWORDS.has(_str):
		return true
	else:
		return false
func at(num = 0) -> G.Token:
	if tokens.size() > 0:
		_s =  tokens[num] as G.Token
		return _s
	else:
		var _err = "An error occurred in '" + str(_s.value) + "' vicinity"
		if out_err:
			G.err.push(0 , _err)
		stop_parse()
		return null
	return null
func is_EOF():
	return  at().type == G.TokenType.EOF
func eat() -> G.Token:
	var _r = at()
	tokens.remove_at(0)
	return _r as G.Token
func expect(val : String,pre_err):
	var prev = eat() as G.Token
	if (not prev) or prev.value != val:
		var _err = String(pre_err).format([val],"{}")
		if out_err:
			G.err.push(0 , _err)
		stop_parse()
		return null
	return prev
func expectt(val : G.TokenType,pre_err):
	var prev = eat() as G.Token
	if (not prev) or prev.type != val:
		var _err = String(pre_err).format([val],"{}")
		if out_err:
			G.err.push(0 , _err)
		stop_parse()
	return prev
func tokens_out():
	var _arr = []
	for i: G.Token in tokens:
		_arr.push_back({ type = i.type , value = i.value})
	return _arr
func body_out(bodys):
	var _arr = []
	for i: AST.ASTNode in bodys:
		_arr.push_back(i.to_json())
	return _arr
func exec() -> Array[AST.ASTNode]:
	var body:Array[AST.ASTNode] = []
	while not is_EOF() and G.is_can_run:
		var _res = parse_stmt()
		body.push_back(_res)
	return body
func parse_stmt():
	var tk : G.Token = at()
	match tk.value:
		G.KEYWORDS.var:
			return parse_variable()
		G.KEYWORDS.fn:
			return parse_fn()
		G.KEYWORDS.if:
			return parse_if()
		G.KEYWORDS.for:
			return parse_for()
		G.KEYWORDS.import:
			return parse_import()
		G.KEYWORDS.return:
			return parse_return()
		G.KEYWORDS.try:
			return parse_trycatch()
		_:
			return parse_expr()
func parse_trycatch():
	eat()
	var ebody = []
	var rbody = []
	var fbody = []
	var _is_err = false
	var _is_finally = false
	while not is_EOF() and at().value != G.KEYWORDS.end and at().value != G.KEYWORDS.catch:
		rbody.push_back(parse_stmt())
	if at().value == G.KEYWORDS.catch:
		eat()
		_is_err = true
		while not is_EOF() and at().value != G.KEYWORDS.end and at().value != G.KEYWORDS.finally:
			ebody.push_back(parse_stmt())
	elif at().value == G.KEYWORDS.finally:
		eat()
		_is_err = true
		while not is_EOF() and at().value != G.KEYWORDS.end:
			fbody.push_back(parse_stmt())
	expect("end","cannot find keywords {}")
	return AST.TryCatchNode.new({
		errBody = ebody,
		runBody = rbody,
		finallyBody = fbody,
	})
func parse_import():
	eat()
	var _path = [parse_primary()]
	if at().value == "as" :
		eat()
		var _aspath = [parse_primary()]
		return AST.ImportASNode.new({
			path = _path,
			as_path = _aspath
		})
	return AST.ImportNode.new({
		path = _path,
	})
func parse_for():
	eat()
	var left = parse_stmt()
	var is_iterate := false
	var mid : AST.ASTNode
	var right : AST.ASTNode
	if at().type == G.TokenType.comma and at().value == ",":
		eat()
		mid =  parse_stmt()
	if at().type == G.TokenType.identifier and at().value == "in":
		eat()
		is_iterate = true
		right =  parse_stmt()
	else:
		expect(",","cannot find token : {}")
		right =  parse_stmt()
	expect(G.KEYWORDS.then,"cannot find token : {}")
	var body : Array[AST.ASTNode] = []
	while not is_EOF() and at().value != G.KEYWORDS.else and at().value != G.KEYWORDS.end:
		body.push_back(parse_stmt())
	expect(G.KEYWORDS.end,"cannot find token : {}")
	return AST.ForNode.new({
		left = left,
		mid = mid,
		right = right,
		body = body,
		is_iterate = is_iterate
	})
func parse_if():
	eat()
	var contidion = parse_expr()
	expect(G.KEYWORDS.then,"cannot find token : {}")
	var body : Array[AST.ASTNode] = []
	while not is_EOF() and at().value != G.KEYWORDS.else and at().value != G.KEYWORDS.end:
		body.push_back(parse_stmt())
	var else_body : Array[AST.ASTNode] = []
	var is_else : bool = false
	if at().value == G.KEYWORDS.else :
		eat()
		while not is_EOF() and at().value != G.KEYWORDS.end:
			else_body.push_back(parse_stmt())
		is_else = true
	expect(G.KEYWORDS.end,"cannot find token : {}")
	return AST.IFNode.new({
		contidion = contidion,
		body = body,
		else_body = else_body,
		is_else = is_else,
	})
func parse_fn():
	eat()
	var _name = expectt(G.TokenType.identifier,"The function is incorrectly formatted")
	var args =  parse_args()
	var body:Array[AST.ASTNode] = []
	while not is_EOF() and at().value != G.KEYWORDS.end:
		body.push_back(parse_stmt())
	expect(G.KEYWORDS.end,"cannot find token : {}")
	return AST.FnNode.new({
		name = _name,
		args = args,
		body = body
	})
func parse_variable():
	var ty = parse_expr()
	var _name = expectt(G.TokenType.identifier,"connot find identify {}")
	var op =  expectt(G.TokenType.binary_op,"connot find opreater")
	var val = parse_expr()
	return AST.VariableNode.new({
		name = AST.IdentifierNode.new({value = _name}),
		type = ty,
		operate = op,
		value = val
	})
func parse_return():
	eat()
	var _val = parse_expr()
	return AST.ReturnNode.new({
		value = _val
	})
func parse_expr():
	return parse_assign()
func parse_assign():
	var left = parse_ternary()
	if at().type == G.TokenType.binary_op and at().value == "=" :
		eat()
		var value = parse_ternary()
		return AST.AssignNode.new({
			left = left,
			value = value,
		})
	return left
func parse_ternary():
	var left = parse_compare()
	if at().type == G.TokenType.qmark and at().value == "?":
		expectt(G.TokenType.qmark,"cannot find token : {}")
		var body : Array[AST.ASTNode] = [parse_expr()]
		var else_body : Array[AST.ASTNode] = []
		var is_else : bool = false
		expectt(G.TokenType.colon,"cannot find token : {}")
		else_body.push_back(parse_expr())
		return AST.TernaryNode.new({
			contidion = left,
			body = body,
			else_body = else_body,
			is_else = is_else,
		})
	return left
func parse_compare():
	var left = parse_object()
	if at().type == G.TokenType.double_bo or [">","<"].find(at().value) != -1:
		var op = parse_object()
		var right = parse_object()
		return AST.CompareNode.new({left = left,operate = op , right = right})
	return left
func parse_object():
	if at().type != G.TokenType.obrace:
		return parse_array()
	eat()
	var _property_arr = [] as Array[AST.ObjectPropertyNode]
	while not is_EOF() and at().type != G.TokenType.cbrace:
		# { key }
		var key = parse_primary()
		if at().type == G.TokenType.comma: # {key ,}
			eat()
			_property_arr.push_back(AST.ObjectPropertyNode.new({
				key = key,
				value = G.Token.new(G.TokenType.nil,null)
			}))
		elif at().type == G.TokenType.cbrace and key is AST.IdentifierNode: # {key}
			_property_arr.push_back(AST.ObjectPropertyNode.new({
				key = key,
				value = G.Token.new(G.TokenType.nil,null)
			}))
		elif at().type == G.TokenType.binary_op and at().value == "=" or key is G.Token and key.type == G.TokenType.string and at().value == ":":
			eat()
			var val = parse_expr()
			_property_arr.push_back(AST.ObjectPropertyNode.new({
					key = key,
					value = val
				}))
			if at().type == G.TokenType.comma:
				eat()
				continue
			else:
				break
		var _err = "cannot identifier object identifier : " + at().value
		if out_err:
			G.err.push(0 , _err)
		stop_parse()
	expectt(G.TokenType.cbrace,"cannot find object identifier {}")
	return AST.ObjectNode.new({
		properties = _property_arr
	})
func parse_array():
	if at().type != G.TokenType.oobracket:
		return parse_call()
	eat()
	var _property_arr = []
	var index = 0
	while not is_EOF() and at().type != G.TokenType.ccbracket:
		var value = parse_expr()
		if at().type ==  G.TokenType.comma:
			eat()
		_property_arr.push_back(AST.ArrayPropertyNode.new({
			value = value,
			index = index,
		}))
		index += 1
	expectt(G.TokenType.ccbracket,"cannot find token : {}")
	return AST.ArrayNode.new({
		properties = _property_arr
	})
func parse_call(nodes = null):
	var left = nodes if nodes else parse_mdExpr()
	if left is AST.IdentifierNode and get_ident(left) == "fn":
		var args = parse_args()
		var _body := []
		while not is_EOF() and at().value != G.KEYWORDS.end:
			_body.push_back(parse_stmt())
		expect("end","connot find anonymous identifier")
		return AST.AnonymousNode.new({
				body = _body,
				args = args,
			})
	elif at().type == G.TokenType.obracket:
		var args = parse_args()
		return AST.CallNode.new({
				name = left,
				args = args,
			})
	return left
func parse_anonymous(_arg : Array):
	eat() # =
	expect(">","cannot find anonymous identifer : {}")
	var _body : Array[AST.ASTNode]
	var _is := false
	while not is_EOF() and at().value != G.KEYWORDS.end:
		var _stmt = parse_stmt()
		if _stmt is AST.ReturnNode:
			_is = true
		_body.push_back(_stmt)
	expect("end","cannot find anonymous identifer : {}")
	return AST.AnonymousNode.new({
		body = _body,
		arg = _arg,
		is_return = _is,
	})
func parse_args():
	expect("(","cannot find token : {}")
	var args = [] if at().type == G.TokenType.cbracket else parse_args_list()
	expect(")","cannot find token : {}")
	return args
func parse_args_list():
	var _arr = [parse_expr()]
	while at().type == G.TokenType.comma and eat():
		_arr.push_back(parse_expr())
	return _arr
func parse_mdExpr():
	var left = parse_addExpr()
	if ["*","/"].find(at().value) != -1:
		var op = parse_addExpr()
		var right = parse_addExpr()
		left =  AST.MdNode.new({left = left,operate = op , right = right})
	return left
func parse_addExpr():
	var left = parse_upExpr()
	while ["+","-"].find(at().value) != -1:
		var op = parse_upExpr()
		var right = parse_expr()
		if left is AST.ASTNode and right is AST.ASTNode :
			left = AST.AddNode.new({left = left,operate = op , right = right})
		else:
			if out_err:
				G.err.push(0,"Wrong addition at : " + str(op.index))
				stop_parse()
	return left
func parse_call_member():
	var member = parse_member()
	if at().type == G.TokenType.obracket:
		return parse_call(member)
	return member
func parse_member():
	var _object = parse_primary()
	if _object is AST.IdentifierNode:
		while at().type == G.TokenType.oobracket or at().type == G.TokenType.dot:
			var ident = eat() as G.Token
			var _val = parse_expr()
			if ident.type == G.TokenType.oobracket:
				expect("]","cannot find token : {}")
			_object = AST.MemberNode.new({
				object = _object,
				property = _val,
			})
	return _object
func parse_upExpr():
	var left = parse_call_member()
	if left is G.Token and ["++","--","**"].find(left.value) != -1:
		var op = parse_primary()
		if op is AST.IdentifierNode:
			return AST.UpdateNode.new({name = op, operate = left , is_left = true })
	elif left is AST.IdentifierNode and ["++","--","**"].find(at(0).value) != -1:
		var op = parse_primary()
		return AST.UpdateNode.new({name = left, operate = op , is_left = false })
	return left
func parse_primary():
	var tk = at()
	match tk.type:
		G.TokenType.identifier:
			eat()
			return AST.IdentifierNode.new({value = tk})
		G.TokenType.num:
			eat()
			return AST.NumNode.new({value = tk})
		G.TokenType.string:
			eat()
			return AST.StringNode.new({value = tk})
		G.TokenType.boolean:
			eat()
			return AST.BoolNode.new({value = tk})
		G.TokenType.binary_op,G.TokenType.double_bo:
			eat()
			return tk
		G.TokenType.obracket:
			expect("(","cannot find token : {}")
			var res = [] if at().type == G.TokenType.cbracket else parse_expr()
			expect(")","cannot find token : {}")
			return res
		G.TokenType.semic:
			eat()
			return tk
		G.TokenType.obrace:
			eat()
			return tk
		G.TokenType.EOF:
			eat()
			return tk
		_:
			var _err = "cannot identified this Token : " + str(tk.value)
			if out_err:
				G.err.push(0 , _err)
			stop_parse()
			return tk

