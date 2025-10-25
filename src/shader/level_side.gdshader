shader_type canvas_item;

uniform float height;

void fragment() {
    vec2 uv = UV;
    uv.y = uv.y * 3.0 + height * 3.0;
    COLOR = texture(TEXTURE, uv);
}
