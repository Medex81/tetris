# Сцена содержит прогресс значение которого меняется из менеджера сцен.
# Стартовая анимация запускается автоматически после добавления в root дерево.
# после завершения стартовой анимации отправляется сигнал в менеджер сцены - анимация перекрыла старую сцену.
# Менеджер сцен увеличивает прогресс и докачивает новую сцену, после докачки сцены менеджер запустит финальную анимацию.
# После завершения финальной анимации сцена самоудалится из дерева.

extends ColorRect

# Отправляем наружу сигналы о состоянии
# После завершения стартовой анимации, удаляем старую сцену и запускаем скачивание новой
signal animation_enter_finished

func _ready():
	print("Transite scene started")
func _exit_tree():
	print("Transite scene exit")
	
func set_progress_value(value:int):
	$TextureProgress.value = value
	if !$TextureProgress.visible:
		$TextureProgress.visible = true

func play_enter_animation():
	$AnimationPlayer.play("enter")
	
func play_exit_animation():
	$AnimationPlayer.play("exit")
	$TextureProgress.visible = false

func _on_AnimationPlayer_animation_finished(anim_name):
	# Сообщаем, что можно запускать загрузку новой сцены и удалить старую
	if anim_name == "enter":
		emit_signal("animation_enter_finished")
	# Самоудалиться после завершения финальной анимации
	if anim_name == "exit":
		queue_free()
