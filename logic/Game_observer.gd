# Обозреватель игры, осуществляет общее управление запуском и остановкой, сохранением.

extends Node

const save_section = "logic_start"

func _ready():
	print("Game observer started")
	var logic_start = State_mgr.get_dict(save_section)
	var start_scene_name = State_mgr.get_value(logic_start, "last_scene", "res://mainD.tscn")
	Scene_mgr.set_main_scene(start_scene_name)



