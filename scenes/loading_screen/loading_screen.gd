extends Control

@export
var progress_bar: ProgressBar

var main_scene: PackedScene = preload("res://scenes/main/Main.tscn")

func _ready() -> void:
	theme = ResourceLibrary.get_theme("default")

func _process(_delta: float) -> void:
	var value: float = ResourceLibrary.get_status()
	if value >= 1.0:
		get_tree().change_scene_to_packed(main_scene)
	progress_bar.value = value
