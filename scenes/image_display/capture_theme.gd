extends Node2D

@export
var foreground: Sprite2D
@export
var background: Sprite2D

const foreground_color_name: StringName = "Accent"
const background_color_name: StringName = "Background"
const clear_color_name: StringName = "Clear"
const theme_name: StringName = "Image"
const shader_parameter_name: StringName = "color"

var current_theme: Theme = ResourceLibrary.get_theme("default"):
	set(value):
		apply_theme(value)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	apply_theme(current_theme)

func apply_theme(value: Theme) -> void:
	foreground.set_instance_shader_parameter(shader_parameter_name, value.get_color(foreground_color_name, theme_name))
	background.set_instance_shader_parameter(shader_parameter_name, value.get_color(background_color_name, theme_name))
	RenderingServer.set_default_clear_color(value.get_color(clear_color_name, theme_name))
