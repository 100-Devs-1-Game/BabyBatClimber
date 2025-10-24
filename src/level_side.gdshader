shader_type canvas_item;

uniform float height;

void fragment() {
    vec2 uv = UV;
    uv.y = uv.y + height;
    COLOR = texture(TEXTURE, uv);
}
