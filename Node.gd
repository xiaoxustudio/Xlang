extends Node
# AST 节点

class ASTNode:
	var NodeType = ""
	func _init(tk : Dictionary) -> void:
		NodeType = tk.kind
	func to_json():
		return {
			kind = NodeType if typeof(NodeType) == TYPE_STRING else NodeType.to_json(),
		}
## 数据类型
class IdentifierNode extends ASTNode:
	var value : G.Token
	func _init(tk : Dictionary) -> void:
		tk.kind = "IdentifierNode"
		super(tk)
		value = tk.value
	func to_json():
		var res = super() as Dictionary
		res.value = value.to_json()
		return res

class StringNode extends ASTNode:
	var value : G.Token
	func _init(tk : Dictionary) -> void:
		tk.kind = "StringNode"
		super(tk)
		value = tk.value
	func to_json():
		var res = super() as Dictionary
		res.value = value.to_json()
		return res

class NumNode extends ASTNode:
	var value : G.Token
	func _init(tk : Dictionary) -> void:
		tk.kind = "NumNode"
		super(tk)
		value = tk.value
	func to_json():
		var res = super() as Dictionary
		res.value = value.to_json()
		return res

class BoolNode extends ASTNode:
	var value : G.Token
	func _init(tk : Dictionary) -> void:
		tk.kind = "BoolNode"
		super(tk)
		value = tk.value
	func to_json():
		var res = super() as Dictionary
		res.value = value.to_json()
		return res

class ObjectNode extends ASTNode:
	var properties : Array
	func _init(tk : Dictionary) -> void:
		tk.kind = "ObjectNode"
		super(tk)
		properties = tk.properties
	func to_json():
		var res = super() as Dictionary
		var _arr = []
		for i:ASTNode in properties:
			_arr.push_back(i.to_json())
		res.properties = _arr
		return res

class ObjectPropertyNode extends ASTNode:
	var value : ASTNode
	var key : ASTNode
	func _init(tk : Dictionary) -> void:
		tk.kind = "ObjectPropertyNode"
		super(tk)
		value = tk.value
		key = tk.key
	func to_json():
		var res = super() as Dictionary
		res.value = value.to_json()
		res.key = key.to_json()
		return res

class MemberNode extends ASTNode:
	var object : ASTNode
	var property : ASTNode
	func _init(tk : Dictionary) -> void:
		tk.kind = "MemberNode"
		super(tk)
		object = tk.object
		property = tk.property
	func to_json():
		var res = super() as Dictionary
		res.object = object.to_json()
		res.property = property.to_json()
		return res

class ArrayPropertyNode extends ASTNode:
	var value : ASTNode
	var index : int
	func _init(tk : Dictionary) -> void:
		tk.kind = "ArrayPropertyNode"
		super(tk)
		value = tk.value
		index = tk.index
	func to_json():
		var res = super() as Dictionary
		res.value = [value.to_json(),index]
		return res

class ArrayNode extends  ASTNode:
	var properties : Array
	func _init(tk : Dictionary) -> void:
		tk.kind = "ArrayNode"
		super(tk)
		properties = tk.properties
	func to_json():
		var res = super() as Dictionary
		var _arr = []
		for i:ASTNode in properties:
			_arr.push_back(i.to_json())
		res.properties = _arr
		return res

class ArrayValNode extends  ArrayNode:
	func _init(tk : Dictionary) -> void:
		super(tk)
		self.NodeType = "ArrayValNode"
	func to_json():
		var res = super() as Dictionary
		return res

class ObjectValNode extends  ASTNode:
	var properties : Dictionary
	func _init(tk : Dictionary) -> void:
		tk.kind = "ObjectValNode"
		super(tk)
		properties = tk.properties
	func to_json():
		var res = super() as Dictionary
		res.properties = properties
		return res

class AnonymousNode extends  ASTNode:
	var body : Array
	var args : Array
	var is_return := false
	func _init(tk : Dictionary) -> void:
		tk.kind = "AnonymousNode"
		super(tk)
		body = tk.body
		args = tk.args
		is_return = false if not tk.has("is_return") else tk.is_return
	func to_json():
		var res = super() as Dictionary
		var _arr = []
		for i in body:
			_arr.push_back(i.to_json())
		res.body = _arr
		var _arr1 = []
		for i in args:
			_arr1.push_back(i.to_json())
		res.args = _arr1
		res.is_return = is_return
		return res
class AnonymousValNode extends  AnonymousNode:
	func _init(tk : Dictionary) -> void:
		super(tk)
		self.NodeType = "AnonymousValNode"
	func to_json():
		var res = super() as Dictionary
		return res

## ————————————————

class MdNode extends ASTNode:
	var left :  ASTNode
	var operate : G.Token
	var right :  ASTNode
	func _init(tk : Dictionary) -> void:
		tk.kind = "MdNode"
		super(tk)
		left = tk.left
		operate = tk.operate
		right = tk.right
	func to_json():
		var res = super() as Dictionary
		res.left = left.to_json()
		res.operate = operate.to_json()
		res.right = right.to_json()
		return res

class AddNode extends ASTNode:
	var left : ASTNode
	var operate : G.Token
	var right : ASTNode
	func _init(tk : Dictionary) -> void:
		tk.kind = "AddNode"
		super(tk)
		left = tk.left
		operate = tk.operate
		right = tk.right
	func to_json():
		var res = super() as Dictionary
		res.left = left.to_json()
		res.operate = operate.to_json()
		res.right = right.to_json()
		return res

class CompareNode extends ASTNode:
	var left : ASTNode
	var operate : G.Token
	var right : ASTNode
	func _init(tk : Dictionary) -> void:
		tk.kind = "CompareNode"
		super(tk)
		left = tk.left
		operate = tk.operate
		right = tk.right
	func to_json():
		var res = super() as Dictionary
		res.left = left.to_json()
		res.operate = operate.to_json()
		res.right = right.to_json()
		return res

class UpdateNode extends ASTNode:
	var name : ASTNode
	var operate : G.Token
	var is_left : bool
	func _init(tk : Dictionary) -> void:
		tk.kind = "UpdateNode"
		super(tk)
		name = tk.name
		operate = tk.operate
		is_left = tk.is_left
	func to_json():
		var res = super() as Dictionary
		res.name = name.to_json()
		res.operate = operate.to_json()
		res.is_left = str(is_left)
		return res

class TernaryNode extends ASTNode:
	var contidion : ASTNode
	var body : Array
	var else_body : Array
	func _init(tk : Dictionary) -> void:
		tk.kind = "TernaryNode"
		super(tk)
		contidion = tk.contidion
		body = tk.body
		else_body = tk.else_body
	func to_json():
		var res = super() as Dictionary
		res.contidion = contidion.to_json()
		var _arr_body = []
		for i:ASTNode in body:
			_arr_body.push_back(i.to_json())
		res.body = _arr_body
		var _arr_ebody = []
		for i:ASTNode in else_body:
			_arr_ebody.push_back(i.to_json())
		res.else_body = _arr_ebody
		return res

class AssignNode extends ASTNode:
	var left : ASTNode
	var value : ASTNode
	func _init(tk : Dictionary) -> void:
		tk.kind = "AssignNode"
		super(tk)
		left = tk.left
		value = tk.value
	func to_json():
		var res = super() as Dictionary
		res.left = left.to_json()
		res.value = value.to_json()
		return res

class CallNode extends ASTNode:
	var name : ASTNode
	var args : Array
	func _init(tk : Dictionary) -> void:
		tk.kind = "CallNode"
		super(tk)
		name = tk.name
		args = tk.args
	func to_json():
		var res = super() as Dictionary
		res.name = name.to_json()
		var _arr = []
		for i:ASTNode in args:
			_arr.push_back(i.to_json())
		res.args = _arr
		return res

class FnNode extends ASTNode:
	var name : G.Token
	var args : Array
	var body : Array
	func _init(tk : Dictionary) -> void:
		tk.kind = "FnNode"
		super(tk)
		name = tk.name
		args = tk.args
		body = tk.body
	func to_json():
		var res = super() as Dictionary
		res.name = name.to_json()
		var _arr = []
		for i:ASTNode in args:
			_arr.push_back(i.to_json())
		res.args = _arr
		var _body = []
		for i:ASTNode in body:
			_body.push_back(i.to_json())
		res.body = _body
		return res

class FnValNode extends ASTNode:
	var name : G.Token
	var caller : Callable
	func _init(tk : Dictionary) -> void:
		tk.kind = "FnValNode"
		super(tk)
		name = tk.name
		caller = tk.caller
	func to_json():
		var res = super() as Dictionary
		res.name = name.to_json()
		res.caller = caller
		return res

class AssignmentNode extends ASTNode:
	var left : ASTNode
	var operate : G.Token
	var right : ASTNode
	func _init(tk : Dictionary) -> void:
		tk.kind = "AssignmentNode"
		super(tk)
		left = tk.left
		operate = tk.operate
		right = tk.right
	func to_json():
		var res = super() as Dictionary
		res.left = left.to_json()
		res.operate = operate.to_json()
		res.right = right.to_json()
		return res

class VariableNode extends ASTNode:
	var name : ASTNode
	var operate : G.Token
	var value : ASTNode
	var type : ASTNode
	func _init(tk : Dictionary) -> void:
		tk.kind = "VariableNode"
		super(tk)
		name = tk.name
		operate = tk.operate
		value = tk.value
		type = tk.type
	func to_json():
		var res = super() as Dictionary
		res.name = name.to_json()
		res.operate = operate.to_json()
		res.value = value.to_json()
		res.type = type.to_json()
		return res

class IFNode extends ASTNode:
	var contidion : ASTNode
	var body : Array
	var is_else : bool
	var else_body : Array
	func _init(tk : Dictionary) -> void:
		tk.kind = "IFNode"
		super(tk)
		contidion = tk.contidion
		body = tk.body
		is_else  = tk.is_else
		else_body = tk.else_body
	func to_json():
		var res = super() as Dictionary
		res.contidion = contidion.to_json()
		res.is_else = str(is_else)
		var _arr_body = []
		for i:ASTNode in body:
			_arr_body.push_back(i.to_json())
		res.body = _arr_body
		var _arr_ebody = []
		for i:ASTNode in else_body:
			_arr_ebody.push_back(i.to_json())
		res.else_body = _arr_ebody
		return res

class ForNode extends ASTNode:
	var left : ASTNode
	var mid
	var right : ASTNode
	var body : Array
	var is_iterate : bool
	func _init(tk : Dictionary) -> void:
		tk.kind = "ForNode"
		super(tk)
		left = tk.left
		mid = tk.mid
		right = tk.right
		body = tk.body
		is_iterate = tk.is_iterate if tk.has("is_iterate") else false
	func to_json():
		var res = super() as Dictionary
		res.left = left.to_json()
		res.mid = null if not mid else mid.to_json()
		res.right = right.to_json()
		var _body = []
		for i:ASTNode in body:
			_body.push_back(i.to_json())
		res.body = _body
		return res

class ImportNode extends ASTNode:
	var path : Array
	func _init(tk : Dictionary) -> void:
		tk.kind = "ImportNode"
		super(tk)
		path = tk.path
	func to_json():
		var res = super() as Dictionary
		var _p = []
		for i:ASTNode in path:
			_p.push_back(i.to_json())
		res.path = _p
		return res

class ImportASNode extends ASTNode:
	var path : Array
	var as_path : Array
	func _init(tk : Dictionary) -> void:
		tk.kind = "ImportASNode"
		super(tk)
		path = tk.path
		as_path = tk.as_path
	func to_json():
		var res = super() as Dictionary
		var _p = []
		for i:ASTNode in path:
			_p.push_back(i.to_json())
		res.path = _p
		var _ap = []
		for i:ASTNode in as_path:
			_ap.push_back(i.to_json())
		res.as_path = _ap
		return res

class ReturnNode extends  ASTNode:
	var value
	func _init(tk : Dictionary) -> void:
		tk.kind = "ReturnNode"
		super(tk)
		value = tk.value
	func to_json():
		var res = super() as Dictionary
		return res

class TryCatchNode extends  ASTNode:
	var errBody : Array
	var runBody : Array
	var finallyBody : Array
	func _init(tk : Dictionary) -> void:
		tk.kind = "TryCatchNode"
		super(tk)
		errBody = tk.errBody
		runBody = tk.runBody
		finallyBody = tk.finallyBody
	func to_json():
		var res = super() as Dictionary
		var _arr = []
		for i in errBody:
			_arr.push_back(i.to_json())
		res.errBody = _arr
		var _arr1 = []
		for i in runBody:
			_arr1.push_back(i.to_json())
		res.runBody = _arr1
		var _arr2 = []
		for i in finallyBody:
			_arr2.push_back(i.to_json())
		res.finallyBody = _arr2
		return res



