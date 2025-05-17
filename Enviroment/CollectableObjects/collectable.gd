extends Node

enum COLLECTABLE_TYPE {
	BREZO,
	CASA
}

signal collectable_value_changed_signal(type:COLLECTABLE_TYPE, new_value:int)

var _objects = {
	COLLECTABLE_TYPE.BREZO : 0,
	COLLECTABLE_TYPE.CASA : 0
}

var _object_used = {
	COLLECTABLE_TYPE.BREZO : 0,
	COLLECTABLE_TYPE.CASA : 0
	
}

var _max_object_value = {
	COLLECTABLE_TYPE.BREZO : 0,
	COLLECTABLE_TYPE.CASA : 0
}

func add_collectable_object(type: COLLECTABLE_TYPE, num:int = 1):
	if num <= 0:
		return 
		
	_objects[type] += num
	collectable_value_changed_signal.emit(type,_objects[type])

func use_collectable_object(type: COLLECTABLE_TYPE, num:int = 1) -> bool:
	if _objects[type] - _object_used[type] < num:
		return false
		
	_object_used[type] += num
	collectable_value_changed_signal.emit(type,_objects[type])
	return true

func get_collectable_value(type: COLLECTABLE_TYPE) -> int:
	return _objects[type]

func get_collectable_unused(type: COLLECTABLE_TYPE) -> int:
	return _objects[type] - _object_used[type]
	
func register_collectable_value(type:COLLECTABLE_TYPE, num:int = 1):
	_max_object_value[type] += num
	
