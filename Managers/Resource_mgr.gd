# Синхронный/асинхронный загрузчик ресурсов с диска
# В синхронном режиме блокируем поток до загрузки ресурса с диска.
# В асинхронном режиме ставим ресурс в очередь закачки в отдельный поток. По
# завершении закачки ресурса отправляем сигнал заказчику ресурса с путём и объектом.
extends Node

var thread
var mutex
var sem
var queue = []
var pending = {}

signal resource_loaded(path, res)
signal resource_progress(path, progress)

func _ready():
	print("Resource manager started")
	mutex = Mutex.new()
	sem = Semaphore.new()
	thread = Thread.new()
	thread.start(self, "thread_func", 0)

func _lock(_caller):
	mutex.lock()

func _unlock(_caller):
	mutex.unlock()

func _post(_caller):
	sem.post()

func _wait(_caller):
	sem.wait()

# Асинхронная загрузка через очередь и поток
func get_resource_async(path):
	_lock("get_resource_async")
	# Уже загружается, ожидайте сообщения
	if path in pending:
		_unlock("get_resource_async")
		return false
	# Ресурс есть в кеше - вернём сразу
	elif ResourceLoader.has_cached(path):
		var res = ResourceLoader.load(path)
		_unlock("get_resource_async")
		return res
	# Ставим ресурс в очередь на загрузку с диска
	else:
		var res = ResourceLoader.load_interactive(path)
		res.set_meta("path", path)
		queue.push_back(res)
		pending[path] = res
		_post("get_resource_async")
		_unlock("get_resource_async")
		return true

# Получить ресурс.
# Если ранее ресурс не был установлен в очередь загрузки - загрузить синхронно.
# Ресурс в очереди - установить его позицию в начало и загрузить заблокировав вызывающий поток.
func get_resource_sync(path):
	return ResourceLoader.load(path)

func thread_process():
	_wait("thread_process")
	_lock("process")
	
	# Запрашиваем путь к ресурсу один раз на старте
	var bPath_get = false
	var path = ""
	while queue.size() > 0:
		var res = queue[0]
		if !bPath_get:
			path = res.get_meta("path")
			bPath_get = true
			
		_unlock("process_poll")
		# Запускаем загрузку шага ресурса
		var ret = res.poll()
		_lock("process_check_queue")
		
		# Шаг загружен. Загрузить следующий шаг в этом ресурсе.
		if ret == OK:
			emit_signal("resource_progress", path, float(queue[0].get_stage()) / float(queue[0].get_stage_count()))
			continue
			
		# Ресурс загружен со всеми зависимостями
		if ret == ERR_FILE_EOF:
			pending[path] = res.get_resource()
		# Ошибка загрузки ресурса
		else:
			pending[path] = -1
		# Отправляем заказчику ресурс и удаляем из списка результатов
		print("RM. Loaded resource ", path)
		emit_signal("resource_loaded", path, pending[path])
		bPath_get = false
		queue.remove(0)
		pending.erase(path)
	_unlock("process")

func thread_func(_u):
	while true:
		thread_process()
