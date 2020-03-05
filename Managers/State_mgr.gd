
extends Node

var _user_data = {}
var _path_to_state = "user://state.json"
var _timer = null
var _save_time_sec = 30

func _ready():	
	_timer = Timer.new()
	_timer.connect("timeout",self,"_on_timer_timeout")
	add_child(_timer)
	_timer.wait_time = _save_time_sec
	_load_data()
	
func _on_timer_timeout():
	save_data()
	
func _exit_tree():
	save_data()

func _load_data():
	var f = File.new()
	if(not f.file_exists(_path_to_state)):
		save_data()
	f.open(_path_to_state, File.READ)
	_user_data = parse_json(f.get_as_text())
	f.close()
	
func save_data():
	var f = File.new()
	f.open(_path_to_state,File.WRITE)   
	f.store_line(to_json(_user_data))
	f.close()
	_timer.start()
	
func get_dict(key):
	if !_user_data.has(key):
		_user_data[key] = {}
	return _user_data[key]
	
func set_dict(key, dict_value):
	_user_data[key] = dict_value
	
func get_value(dict, key, default):
	return dict[key] if dict.has(key) else default
