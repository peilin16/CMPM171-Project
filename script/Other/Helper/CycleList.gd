extends Resource
class_name Cyclic_list


var items: Array
var current_index: int = 0

func _init(initial_items: Array = []):
	items = initial_items.duplicate()

func setup(i:Array)->void:
	items = i;

func get_value_by_index(index:int = -1):
	if index < 0 :
		return null;
	while index >= items.size():
		index -= items.size()
	
	return items[index];
func get_value(index:int = -1, is_move:bool = true):
	if items.is_empty():
		return null
	var value
	if index == -1:
		value = items[current_index]
	else:
		value = items[index]
	if not is_move:
		return value;
	current_index += 1
	if current_index>= items.size():
		current_index = 0;
	return value

func get_current():
	if items.is_empty():
		return null
	return items[current_index]

func get_previous():
	var value = items[current_index]
	current_index -= 1
	if current_index<0:
		current_index = items.size() - 1;
	return value

func reset():
	current_index = 0
	items.clear();

func is_empty()->bool:
	return items.is_empty();

func add_item(item):
	items.append(item)
