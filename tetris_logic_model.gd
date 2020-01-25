extends Node

# Размерность игрового поля
var col_count
var row_count

# Модель игрового поля
var model_array = []

var shape_width = 4

# Фигуры в массивах координат
# Квадрат
var s_square = [
	[0,0],[1,0],
	[0,1],[1,1]
]
# Треугольник
var s_trigon = [
		  [1,0],
	[0,1],[1,1],[2,1]
]
# Z
var s_zet = [
	[0,0],[1,0],
		  [1,1],[2,1]
]

var s_zet_inv = [
		  [1,0],[2,0],
	[0,1],[1,1]
]
# Тяпка
var s_ru_g = [
	[0,0],[1,0],[2,0],
	[0,1]
]
var s_ru_g_inv = [
	[0,0],[1,0],[2,0],
				[2,1],
]
# Палка
var s_row = [
	[0,0],[1,0],[2,0],[3,0]
]

# Массив фигур для генерации в игровом поле
var shapes = [s_square, s_trigon, s_zet, s_ru_g, s_row, s_zet_inv, s_ru_g_inv]
# Текущая фигура отображаемая в игровом поле
var current_shape
var next_shape_idx = null
# Словарь со смещениями фигур в зависимости от нажатой кнопки
var direct = {"ui_left": [-1, 0], "ui_right": [1, 0], "ui_down": [0, 1], "ui_up": [0, 0]}
# Варианты столкновения фигур с объектами игрового поля
enum {E_NONE, E_WALLS, E_BOTTOM, E_SHAPES}
# Номер хода
var current_step = 0
enum {E_RUN, E_STOP}
var GameState = E_STOP
var collaide = E_NONE

var level = 1
var score = 0
var match_to_next_level = 20
var current_match = 0
var match_cost = 10
var bMatched = false

func get_next_shape_idxs():
	var idxs = []
	if next_shape_idx:
		for point in shapes[next_shape_idx]:
			idxs.append(shape_width * point[1] + point[0])
	return idxs

# Инициализируем игровое поле новым размером
func init(cols, rows):
	randomize()
	row_count = rows
	col_count = cols
	for i in range(row_count * col_count):
    	model_array.append(0)
		
# Стартуем новую игру и показываем фигуру
func start():
	for i in range(row_count * col_count):
    	model_array[i] = 0
		
	GameState = E_RUN
	level = 1
	score = 0
	match_to_next_level = 20
	current_match = 0
	bMatched = false
	next_shape_idx = null
	
	add_shape()
	
# Добавляем фигуру на игровое поле
func add_shape():
	current_step = 0
	if next_shape_idx:
		current_shape = shapes[next_shape_idx].duplicate(true)
	else:
		current_shape = shapes[rand_range(0, shapes.size())].duplicate(true)
		
	# Генерируем случайную фигуру с копированием массивов координат ячеек
	next_shape_idx = rand_range(0, shapes.size())
	# Смещаем фигуру на середину игрового поля по горизонтали
	var trans_vec = [col_count / 2 - current_shape.size() / 2, 0]
	# Проверяем не выйдет ли фигура за пределы игрового поля
	if has_collaide(current_shape, trans_vec) == E_NONE:
		# Сдвигаем фигуру и сохраняем в ней новые координаты на указанный вектор
		translate_shape(current_shape, trans_vec)
		
# Вращаем фигуру в игровом поле вокруг локальной начальной точки отсчёта
func rotate_shape(shape, rotate):
	# rotate origin
	var origin_pos = shape[shape.size() / 2].duplicate()
	for item in shape:
		# 2d matrix
		var pos = Transform2D(Vector2(item[0], 0), Vector2(0, item[1]), Vector2(origin_pos[0], origin_pos[1]))
		pos = pos.rotated(rotate)
		# origin offset
		pos = Vector2(pos.y.x, pos.x.y) - pos.origin
		# new position
		item[0] = int(origin_pos[0] + pos.x)
		item[1] = int(origin_pos[1] + pos.y)
	
# Сдвигаем фигуру на вектор	
func translate_shape(shape, trans_vec):
	for item in shape:
		item[0] += trans_vec[0]
		item[1] += trans_vec[1]

# Проверяем фигуру на столкновение с объектами игрового поля и выход за пределы
func has_collaide(shape, trans_vec):
	for item in shape:
		# Левая, правая и верхняя границы игрового поля
		if item[0] + trans_vec[0] < 0 \
		|| item[0] + trans_vec[0] > col_count - 1 \
		|| item[1] + trans_vec[1] < 0:
			return E_WALLS
			
		# Горизонтальное столкновение с предыдущими фигурами
		if item[1] < row_count && model_array[col_count * item[1] + item[0] + trans_vec[0]]:
				return E_WALLS

		# Дошли до нижней границы - завершение падения
		if item[1] + trans_vec[1] > row_count - 1:
			return E_BOTTOM

		# Столкнулись с предыдушими фигурами# Вертикальное столкновение с предыдущими фигурами - завершение падения
		if item[1] < row_count - 1 && model_array[col_count * (item[1] + 1) + item[0]]:
			return E_SHAPES
			
	# Нет столкновений - можно двигаться
	return E_NONE
	
# Проверяем на сборку строки
func check_match():
	var tmp_matches = 0
	var tmp_score = 0
	# проверить все строки на матчинг
	for row in range(row_count):
		var matched = true
		# Проходим по строке
		for col in range(col_count):
			# Есть пустая ячейка в строке
			if model_array[col_count * row + col] == 0:
				matched = false
				break
		
		if matched && row > 0:
			tmp_matches += 1
			tmp_score += match_cost
			# Сдвигаем массив строк выше текущей на одну позицию вниз начиная снизу-вверх
			for row_ in range(row, 0, -1):
				# Проходим по строке
				for col_ in range(col_count):
					model_array[col_count * row_ + col_] = model_array[col_count * (row_ - 1) + col_]	
	# тут можно сохранять статистику и награждать
	if tmp_matches:
		current_match += tmp_matches
		level = int(current_match / match_to_next_level + 1)
		score += tmp_score * tmp_matches * level
		bMatched = true
		
func set_outer_reward(reward):
	score += reward * level
		
func get_level_percent():
	var tmp_match = current_match % match_to_next_level
	return (tmp_match * 100) / match_to_next_level
	
func is_stop():
	return true if GameState == E_STOP else false
	
func is_close_step():
	return true if collaide == E_SHAPES || collaide == E_BOTTOM else false
	
# Делаем шаг фигурой в игровом поле	
func next_step(key = ""):
	
	if GameState == E_STOP:
		return false
		
	# Кнопки управления
	if direct.has(key):
		
		current_step += 1
		
		for item in current_shape:
			model_array[col_count * item[1] + item[0]] = 0
			
		# Результат проверки на столкновения
		collaide = E_NONE
		match(key):
			# Смещение
			"ui_left", "ui_right", "ui_down":
				collaide = has_collaide(current_shape, direct[key])
				# Нет столкновения - сдвигаем
				if collaide == E_NONE:
					translate_shape(current_shape, direct[key])
			# Поворот
			"ui_up":
				# Временная фигура для проверки
				var tmp_shape = current_shape.duplicate(true)
				# Поворачиваем на 90 градусов
				rotate_shape(tmp_shape, PI / 2)
				collaide = has_collaide(tmp_shape, direct[key])
				# Нет столкновения - сдвигаем
				if collaide == E_NONE:
					current_shape = tmp_shape
		
		# Фигура столкнулась с нижней гранцей или старыми фигурами
		# Стали впритык на предыдущем шаге
		if collaide == E_SHAPES || collaide == E_BOTTOM:
			# Записываем позицию текущей фигуры в массив игрового поля как артефакт
			for item in current_shape:
				model_array[col_count * item[1] + item[0]] = 1
				
			if current_step == 1:
				GameState = E_STOP
				return false
				
			# Ищем собранные строки
			check_match()
			
			# Запускаем следующую фигуру
			add_shape()
	
		# Записываем позицию текущей фигуры в массив игрового поля
		for item in current_shape:
			model_array[col_count * item[1] + item[0]] = 1
	return true
