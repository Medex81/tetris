# Загрузка последней сохранённой сцены.
# Переключение сцен.
# Стек сцен для возврата.
# Загрузка сцены в бекэнде, отображение транзитной сцены.
# Управление префабами не принадлежащими конкретной сцене.
# Остановка в паузе и продолжение.

extends Node

# Транзитную сцену устанавливаем в конкретной реализации или оставляем по умолчанию
export (PackedScene) var transit_scene_res = preload("res://Managers/Scenes/Transite_scene.tscn")

# Путь к загружаемой сцене
var loading_scene = ""
# Указатель на узел транзитной сцены
var transite_scene = null
# Сигнал с именем загруженной новой сцены
signal scene_changed(name)

func _ready():
	print("Scene manager started")
	Resource_mgr.connect("resource_loaded", self, "on_scene_loaded")
	Resource_mgr.connect("resource_progress", self, "on_scene_loading_progress")

# Сцена загружена с диска в виде пакета с ресурсами
func on_scene_loaded(path:String, resource:PackedScene):
	var root = get_tree().get_root()
	# Это нужная нам сцена
	if loading_scene == path:
		var new_scene = resource.instance()
		new_scene.visible = false
		root.add_child(new_scene)
		# Устанавливаем транзитную сцену последней в дереве
		if transite_scene && root.get_child_count() > 1:
			root.move_child(transite_scene, root.get_child_count() - 1)
			new_scene.visible = true
			# Запускаем анимацию после которой транзитная сцена самоудалится 
			transite_scene.play_exit_animation()
			transite_scene = null
			emit_signal("scene_changed", path.get_file().get_basename())
			print("Enter to scene ", path.get_file().get_basename())

# Инкремент значения в прогрессе транзитной сцены	
func on_scene_loading_progress(path:String, value):
	if transite_scene:
		transite_scene.set_progress_value(value * 100)
		print("Loading progress... ", value)

# В транзитной сцене завершилась стартовая анимация с фейдером	
func on_transite_scene_animation_enter_finished():
	if !transite_scene:
		return
	# Удаляем старую сцену если есть
	var root = get_tree().get_root()
	if root.get_child_count() > 1:
		var old_scene = root.get_child(root.get_child_count() - 2)
		old_scene.queue_free()
		
	# Начали подкачивать в фоне
	Resource_mgr.get_resource_async(loading_scene)
	print("Loading scene... ", loading_scene)

# Установим новую сцену
# Смена сцен:
# -Запускаем транзитную сцену устанавливая её в root после текущей.
# -Транзитная сцена фейдид в анимации(запуск на старте автоматически) окно и показывает прогресс
# -Получаем сигнал от транзитной сцены о завершении анимации фейда, старая сцена закрыта - удаляем её
# -Запускаем загрузку новой сцены, прогресс загрузки передаём в транзитную сцену
# -Загрузка новой сцены завершена, устанавливаем её в дерево перед транзитной(вместо основной)
# -Запускаем в транзитной сцене анимацию завершения перехода(после завершения анимации сцена самоудалиться)  
func set_main_scene(path:String):
	# Сцена которую грузим с диска
	if path.empty():
		return
	loading_scene = path
	# Запускаем транзитную сцену если она раньше не была запущена
	if transite_scene == null && get_tree().get_root().get_child_count() > 0:
		# Стартовая анимация запускается автоматически
		transite_scene = transit_scene_res.instance()
		# Ждём завершения анимации
		transite_scene.connect("animation_enter_finished", self, "on_transite_scene_animation_enter_finished")
		# Транзитная сцена добавляется в дерево и стартует
		get_tree().get_root().call_deferred("add_child", transite_scene)
		transite_scene.play_enter_animation()

