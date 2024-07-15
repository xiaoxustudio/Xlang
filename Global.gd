extends Node
# 全局

var err = Error.new()
var is_can_run = true
static var lex := Lexer.new() as Lexer

func is_alpha(te):
	var regex = RegEx.new()
	regex.compile("([a-zA-Z])")
	var result = regex.search(te)
	if result:
		return true
	else:
		return false
func is_str(te):
	var regex = RegEx.new()
	regex.compile("([0-9])")
	var result = regex.search(te)
	if result:
		return true
	else:
		return false
func is_num(te):
	var regex = RegEx.new()
	regex.compile("(\\d)")
	var result = regex.search(te)
	if result:
		return true
	else:
		return false

func is_skip(te):
	if te == " " or te == "\r" or te == "" or te == "	":
		return true
	else:
		return false

enum TokenType {
	identifier,
	string,
	num,
	boolean,
	obrace, # {
	cbrace,# }
	obracket,# (
	cbracket, # )
	oobracket,# [
	ccbracket, # ]
	semic, # ;
	colon, # :
	comma, # ,
	qmark, # ?
	dot, # .
	double_bo, # 双操作符: += == -= ++ -- *= /= != 
	binary_op, # 赋值操作符: + - * / = 
	unknow,
	nil, # null
	EOF,
}

const KEYWORDS = {
	"import" : "import",
	"as" : "as" ,
	"from" : "from",
	"var" : "var",
	"if" : "if",
	"then" : "then",
	"else" : "else",
	"end" : "end",
	"fn" : "fn",
	"return" : "return",
	"for" : "for",
	"in" : "in",
	"true" : "true",
	"false" : "false",
	"try" : "try",
	"catch" : "catch",
	"finally" : "finally",
}


# 令牌标识
class Token:
	var type = -1
	var value = ""
	var lines : int = -1
	var index : int = -1
	func _init(tp,val,l = -1,i = -1) -> void:
		type = tp
		value = val
		lines = l
		index = i
	func to_json():
		return {
			type = type,
			value = value,
			lines = lines,
			index = index,
			}


func set_highLight(text_edit):
	var _ch = CodeHighlighter.new()
	var _key =  Color(1, 0.412, 0.118,0.8)
	var _men = Color(0.737, 0.878, 1)
	_ch.number_color = _men
	_ch.symbol_color = _men
	_ch.member_variable_color = _men
	_ch.function_color = Color(0.5, 0.5, 1)
	_ch.keyword_colors = {
		"import": Color(0, 0.7, 0.8),
		"as": Color(0, 0.7, 0.8),
		"from": Color(0.4, 0.58, 0.7),
		"var": Color(0.8, 0.325, 0.439),
		"fn":  _key,
		"return" : _key,
		"end": _key,
		"if": _key,
		"for": _key,
		"in": _key,
		"then": _key,
		"else": Color(0.545098, 0, 0, 1),
		"null": _men,
		"try": _key,
		"catch": _key,
		"finally": _key,
	}
	text_edit.syntax_highlighter = _ch

func enable_run():
	G.is_can_run = true

func disable_run():
	G.is_can_run = false
