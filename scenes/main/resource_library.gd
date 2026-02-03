extends Node

const config_location: String = "res://config.ini"

var images: Dictionary[StringName, Texture2D]
var audios: Dictionary[StringName, AudioStream]
var themes: Dictionary[StringName, Theme]
var config: ConfigFile

var loading_resources: Dictionary[String, float]

func _ready() -> void:
	# Minimal blocking load (to ensure everything else can function)
	config = ConfigFile.new()
	var response = config.load(config_location)
	if response != OK:
		_panic("Failed to load config file: ", response)
	
	for resource in config.get_section_keys("MinimalLoad"):
		var resource_name: StringName = config.get_value("MinimalLoad", resource)
		var val = load(resource_name)
		if val is Texture2D:
			images[resource_name] = val
		elif val is AudioStream:
			audios[resource_name] = val
		elif val is Theme:
			themes[resource_name] = val
	
	# Background load the remaining resources
	for file_name in ResourceLoader.list_directory("res://resources/images"):
		loading_resources["res://resources/images/" + file_name] = 0.0
		ResourceLoader.load_threaded_request("res://resources/images/" + file_name, "Texture2D", true, ResourceLoader.CACHE_MODE_REUSE)
	for file_name in ResourceLoader.list_directory("res://resources/audio"):
		loading_resources["res://resources/audio/" + file_name] = 0.0
		ResourceLoader.load_threaded_request("res://resources/audio/" + file_name, "AudioStream", true, ResourceLoader.CACHE_MODE_REUSE)
	for file_name in ResourceLoader.list_directory("res://resources/themes"):
		loading_resources["res://resources/themes/" + file_name] = 0.0
		ResourceLoader.load_threaded_request("res://resources/themes/" + file_name, "Theme", true, ResourceLoader.CACHE_MODE_REUSE)
	
	# Background load external resources
	for file_name in DirAccess.get_files_at("res://resources/images"):
		if file_name.ends_with(".png"):
			loading_resources["res://resources/images/" + file_name] = 0.0
			ResourceLoader.load_threaded_request("res://resources/images/" + file_name, "Texture2D", true, ResourceLoader.CACHE_MODE_REPLACE)
			
	for file_name in DirAccess.get_files_at("res://resources/audio"):
		if file_name.ends_with(".wav"):
			loading_resources["res://resources/audio/" + file_name] = 0.0
			ResourceLoader.load_threaded_request("res://resources/audio/" + file_name, "AudioStream", true, ResourceLoader.CACHE_MODE_REPLACE)
	
	for file_name in DirAccess.get_files_at("res://resources/themes"):
		if file_name.ends_with(".tres"):
			loading_resources["res://resources/themes/" + file_name] = 0.0
			ResourceLoader.load_threaded_request("res://resources/themes/" + file_name, "Theme", true, ResourceLoader.CACHE_MODE_REPLACE)

func get_image(id: StringName) -> Texture2D:
	return images.get(id, images["res://resources/images/default.png"])

func get_audio(id: StringName) -> AudioStream:
	return audios.get(id, audios["res://resources/audio/default.wav"])

func get_theme(id: StringName) -> Theme:
	return themes.get(id, themes["res://resources/themes/default.tres"])

func get_config() -> ConfigFile:
	return config

func save_config(config_to_save: ConfigFile) -> void:
	config_to_save.save(config_location)

func get_status() -> float:
	var total_resources: float = loading_resources.size()
	if total_resources == 0.0:
		return 1.0
		
	var loaded_resources: float = 0.0
	var shared_array = [0.0]
	for resource in loading_resources.keys():
		if loading_resources[resource] != 1.0:
			var status = ResourceLoader.load_threaded_get_status(resource, shared_array)
			if status == ResourceLoader.THREAD_LOAD_FAILED || status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				_panic("Failed to load resource '" + resource + "'", status)
			loading_resources[resource] = shared_array[0]
		loaded_resources += loading_resources[resource]
	return loaded_resources / total_resources

func _panic(message: String, error: Variant) -> void:
	printerr(message, error)
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
