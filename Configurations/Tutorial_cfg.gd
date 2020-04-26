# Конфигурация тутора. Создаём объект контейнер содержащий настройки шагов тутора.
# Шаг тутора сцены описывает состояние сцены тутора.
# Состояние сцены - это условие запуска и завершения, текст, анимация.

extends Node

# набор пакетов туторов по сценам
# имя переменной "container" должно быть всегда и только таким тогда оно будет прочитано в менеджере тутора
var container = {
	# шаг тутора
	"step_1": {
		# Если в сцене есть нод с таким именем - запустить сцену тутора
		"condition_start": {
			"node": "ButtonStart",
			"scene": "mainD"
		},
		# Показать текст сообщения, он разместится на свободной части экрана
		"hint": "sa_mainD_tutor_step_1",
		# Показываем анимацию указателя на нод
		# 0 - arrow, 1 - hand
		"animation": 0,
		# Если указан нод - значит клик должен быть в его проекции, иначе клик в любом месте
		"condition_stop": {
			"node": "ButtonStart"
		},
	}
}