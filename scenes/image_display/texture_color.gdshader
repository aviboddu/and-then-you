shader_type canvas_item;

instance uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	COLOR = vec4(color.r, color.g, color.b, COLOR.a);
}