extends Node
## JSON data loader utility. Loads game data from the /data directory.

static func load_json(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		push_error("JsonLoader: File not found: %s" % file_path)
		return {}
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("JsonLoader: Failed to open: %s (error %d)" % [file_path, FileAccess.get_open_error()])
		return {}
	var json_string: String = file.get_as_text()
	file.close()
	var json: JSON = JSON.new()
	var error: Error = json.parse(json_string)
	if error != OK:
		push_error("JsonLoader: Parse error in %s at line %d: %s" % [file_path, json.get_error_line(), json.get_error_message()])
		return {}
	return json.get_data()

static func load_data_array(file_name: String) -> Array:
	var data: Dictionary = load_json("res://data/%s" % file_name)
	if data.is_empty():
		return []
	if data.has("items"):
		return data["items"]
	return []

static func load_data_dict(file_name: String) -> Dictionary:
	return load_json("res://data/%s" % file_name)
