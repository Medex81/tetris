# Шаги в сцене выполнятся в том порядке в котором происходит появление на сцене указанных виджетов.
# Выполненный тутор записывается в менеджер состояния и инитит менеджер тутора при запуске.
# Менеджер тутора ожидает запуска менеджера состояния и затем инитится сам удаляя из объекта конфигурации уже пройденные туторы.

extends Node

# секция пройденных шагов тутора
const save_section_name = "tutors"
const closed_tutors_section_name = "closed_tutors_section"
# список пройденных туторов
var closed_tutors_list:PoolStringArray
# нод с настройками для шагов тутора, поставляется отдельно и привязан к конкретному проекту
var tutor_cfg = preload("res://Configurations/tutorial_cfg.gd")

func _ready():
	print("Tutorial manager started")
	Scene_mgr.connect("scene_changed", self, "on_scene_changed")
	# загрузить список уже пройденных туторов из конфигурации состояния игры
	_deserialize()
	# загружаем скрипт и создаём нод с настройками тутора
	if tutor_cfg == null:
		return
	else:
		# удалим из ноды с настройками шаги которые уже были пройдены ранее
		if tutor_cfg.get("container") && tutor_cfg.container.size() > 0:
			for tutor_name in closed_tutors_list:
				tutor_cfg.container.erase(tutor_name)

func set_cfg_path(path:String):
	pass
			
func on_scene_changed(name:String):
	print("TM. Scene changed. Need check...", name)
	
func _serialize():
	var tutor_section = {
	closed_tutors_section_name: closed_tutors_list}
	State_mgr.set_dict(save_section_name, tutor_section)
	
func _deserialize():
	var tutor_dict = State_mgr.get_dict(save_section_name)
	closed_tutors_list = State_mgr.get_value(tutor_dict, closed_tutors_section_name, [])
