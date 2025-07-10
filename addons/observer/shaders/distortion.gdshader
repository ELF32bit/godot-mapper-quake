shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

uniform vec4 tint: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float speed = 1.0;
uniform float intensity = 0.025;


void fragment() {
	float uv_x = SCREEN_UV.x + intensity * sin(TIME * speed + SCREEN_UV.y * 25.0);
	float uv_y = SCREEN_UV.y + intensity * sin(TIME * speed + SCREEN_UV.x * 25.0);
	vec2 uv_offset = vec2(uv_x, uv_y);
    COLOR = textureLod(SCREEN_TEXTURE, uv_offset, 0.0) * tint;
}