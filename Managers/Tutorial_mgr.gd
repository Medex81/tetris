# Шаги в сцене должны выполнятся последовательно в том порядке в котором описаны в пакете, а запускаться по условию.
# Пока предыдущий шаг не выполнен, следующий не запустится даже если условия подходят.
# Выполненный шаг записывается в менеджер состояния и инитит менеджер тутора при запуске.
# Менеджер ожидает запуска менеджера состояния и затем инитится сам удаляя из объекта конфигурации уже пройденные шаги.

extends Node
# секция сохраняемых параметров тутора
const save_section = "tutor_steps"
# секция пройденных шагов тутора
const closed_steps_section = "closed_steps"

# при разработке проекта указываем в настройках инспектора путь к файлу конфигурации тутора
export (String) var path_to_cfg
# список пройденных шагов тутора
var closed_steps:PoolStringArray
# нод с настройками для шагов тутора, поставляется отдельно и привязан к конкретному проекту
var tutor_cfg = null

func _ready():
	# загрузить список уже пройденных туторов из конфигурации состояния игры
	_deserialize()
	# загружаем скрипт и создаём нод с настройками тутора
	if !path_to_cfg.empty():
		tutor_cfg = load(path_to_cfg)
	else:
		return
	# удалим из ноды с настройками шаги которые уже были пройдены ранее
	if tutor_cfg.get("container") && tutor_cfg.container.size() > 0:
		for step in closed_steps:
			tutor_cfg.container.erase(step)
	# 

func _notification(what):
		

func _serialize():
	var tutor_steps = {
	closed_steps_section: closed_steps}
	State_mgr.set_dict(save_section, tutor_steps)
	
func _deserialize():
	var tutor_steps = State_mgr.get_dict(save_section)
	closed_steps = State_mgr.get_value(tutor_steps, closed_steps_section, [])
