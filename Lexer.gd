extends Node
class_name Lexer
# 词法分析器

var _arr : Array = []
var _char_no = RegEx.create_from_string("[a-zA-Z0-9_]")
# 分词函数
func tokenlize(te : String):
	clear()
	var is_skip = false #全局跳过
	var _skip_char = ""
	var lines = 0 # 行
	var index = 0 
	while te.length() > 0 and G.is_can_run:
		var _s = te[0]
		# 计算行号
		if is_skip and ["+","-","*","/"].find(_s) == -1:
			te = te.erase(0,1)
			index +=1
			continue
		if G.is_alpha(_s):
			var id = ""
			while  te.length() > 0 and _char_no.search(te[0]) is RegExMatch and not G.is_skip(te[0]):
				id += te[0]
				te = te.erase(0,1)
				index +=1
			if ["true","false"].find(id) != -1:
				_arr.push_back(G.Token.new(G.TokenType.boolean,id,lines,index))
				continue
			_arr.push_back(G.Token.new(G.TokenType.identifier,id,lines,index))
			continue
		elif G.is_num(_s):
			var num = ""
			while  te.length() > 0 and G.is_num(te[0]) :
				num += te[0]
				te = te.erase(0,1)
				index +=1
			_arr.push_back(G.Token.new(G.TokenType.num,num,lines,index))
			continue
		elif _s == "\"" or _s == "'":
			var _str = ""
			te = te.erase(0,1)
			index +=1
			while te.length() > 0 :
				_str += te[0]
				te = te.erase(0,1)
				index +=1
				if (te[0] == "\"" or te[0] == "'"):
					break
			te = te.erase(0,1)
			index +=1
			_arr.push_back(G.Token.new(G.TokenType.string,_str,lines,index))
			continue
		elif G.is_skip(_s):
			te = te.erase(0,1)
			index +=1
			continue
		elif _s == "\n":
			index = 0
			lines +=1
			te = te.erase(0,1)
			index +=1
			continue
		elif _s == "{":
			_arr.push_back(G.Token.new(G.TokenType.obrace,_s,lines,index))
		elif _s == "}":
			_arr.push_back(G.Token.new(G.TokenType.cbrace,_s,lines,index))
		elif _s == "(":
			_arr.push_back(G.Token.new(G.TokenType.obracket,_s,lines,index))
		elif _s == ")":
			_arr.push_back(G.Token.new(G.TokenType.cbracket,_s,lines,index))
		elif _s == "[":
			_arr.push_back(G.Token.new(G.TokenType.oobracket,_s,lines,index))
		elif _s == "]":
			_arr.push_back(G.Token.new(G.TokenType.ccbracket,_s,lines,index))
		elif _s == ";":
			_arr.push_back(G.Token.new(G.TokenType.semic,_s,lines,index))
		elif _s == ":":
			_arr.push_back(G.Token.new(G.TokenType.colon,_s,lines,index))
		elif _s == ",":
			_arr.push_back(G.Token.new(G.TokenType.comma,_s,lines,index))
		elif _s == "?":
			_arr.push_back(G.Token.new(G.TokenType.qmark,_s,lines,index))
		elif _s == ".":
			_arr.push_back(G.Token.new(G.TokenType.dot,_s,lines,index))
		elif ["=",">","<","!"].find(_s) != -1:
			if te[1] == "=":
				_arr.push_back(G.Token.new(G.TokenType.double_bo,_s + te[1],lines,index))
				te = te.erase(0,2)
				index +=2
				continue
			_arr.push_back(G.Token.new(G.TokenType.binary_op,_s,lines,index))
		elif ["+","-","*","/"].find(_s) != -1:
			# 注释判断
			if _s == "/" and te[1] == "*" and not is_skip:
				is_skip = true
				te = te.erase(0,2)
				index +=2
				continue
			elif _s == "*" and te[1] == "/" and is_skip:
				is_skip = false
				te = te.erase(0,2)
				index +=2
				continue
			elif is_skip:
				te = te.erase(0,1)
				index +=1
				continue
			# 其他
			if te[1] == "=" or (["+","-","*"].find(_s)!=-1 and ["+","-","*"].find(te[1])!=-1 and _s == te[1]):
				_arr.push_back(G.Token.new(G.TokenType.double_bo,_s + te[1],lines,index))
				te = te.erase(0,2)
				index +=2
				continue
			else:
				_arr.push_back(G.Token.new(G.TokenType.binary_op,_s,lines,index))
		else:
			_arr.push_back(G.Token.new(G.TokenType.unknow,_s,lines,index))
			assert(false,"connot Identify ： " + _s )
		te = te.erase(0,1)
		index += 1
	_arr.push_back(G.Token.new(G.TokenType.EOF,"EOF"))
	return _arr

func clear():
	_arr =[]
