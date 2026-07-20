shader_type canvas_item;

uniform float blur_amount = 1.5;

void fragment()
{
    vec2 offset = TEXTURE_PIXEL_SIZE * blur_amount;

    COLOR =
        texture(TEXTURE, UV + vec2(-offset.x,0)) +
        texture(TEXTURE, UV + vec2(offset.x,0)) +
        texture(TEXTURE, UV + vec2(0,-offset.y)) +
        texture(TEXTURE, UV + vec2(0,offset.y));

    COLOR /= 4.0;
}