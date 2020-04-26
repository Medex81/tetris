# Сцену активирует менеджер тутора, она должна перекрывать всё игровое поле.
# Завершается сцена после отклика пользователя (тача, свапа и т.д.), это событие передаётся
# в менеджер который принимает решение о завершении шага тутора.
# Аргументы окна: 
# - анимация(кисть с пальцем, стрелка),
# - текст подсказки, 
# - позиция и размер дырки,
# - затемняем фон,
# - пропускаем тачи

extends ColorRect 

enum {E_ARROW, E_HAND}
var back_swallowTouch:bool = false

func _ready():
	pass

func init(anim:int = -1,
	hint_text:String = "",
	hole_pos:Vector2 = Vector2.ZERO,
	hole_size:Vector2 = Vector2.ZERO,
	back_shadow:bool = false,
	back_swallowTouch:bool = false ):
		$Text.text = tr(hint_text)
		color.a = 128 if back_shadow else 0
		material.set_shader_param("norm_pos", hole_pos)
		material.set_shader_param("norm_size", hole_size)
		match(anim):
			E_ARROW:
				pass
			E_HAND:
				pass
	
