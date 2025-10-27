shader_type canvas_item;

uniform float height;
uniform float height_factor= 3.0;


void fragment() {
    vec2 uv = UV;
    uv.y = uv.y + height * height_factor;
    COLOR = texture(TEXTURE, uv);
}
