shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

void fragment() {
    // Sample what's underneath this cursor pixel
    vec3 background_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
    
    // Invert background color
    vec3 inverted = vec3(1.0) - background_color;
    
    // Sample cursor texture (cursor image) so you can use its alpha mask / texture
    vec4 cursor_tex = texture(TEXTURE, UV);
    
    // Combine: Use inverted background inside cursor shape where cursor is opaque;
    // Where cursor is transparent, let it be transparent.
    COLOR = vec4(inverted, 1.0) * cursor_tex.a;
}
