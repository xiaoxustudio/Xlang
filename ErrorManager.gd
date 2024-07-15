extends Node
class_name Error

var _message : Array[Message]
var _th : Thread

enum Mtype {
	error,
	warning,
	none,
}

class Message:
	var text : String = ""
	var type : Mtype = Mtype.error
	func _init(ty : Mtype = Mtype.error,te := "") -> void:
		text = te
		type = ty

func _init() -> void:
	_message = []


func push(type: int ,text := ""):
	_message.append(Message.new(type,text))
	var tag = "red" if _message[0].type == Mtype.error else "yellow" if _message[0].type == Mtype.warning else "white"
	var e_name = "Error" if _message[0].type == Mtype.error else "Warning" if _message[0].type == Mtype.warning else "Log"
	if e_name == "Error":
		G.is_can_run = false
	print_rich(("<[color={0}]".format([tag])) + e_name + "[/color]>:" +  _message[0].text )
	_message.pop_front()

