shader_type canvas_item;

uniform float _min:hint_range(0.0, 1.0, 0.001);
uniform float _max:hint_range(0.0, 1.0, 0.001);
uniform vec4 new_color:hint_color;

// From: https://gamedev.stackexchange.com/a/75928
vec3 rgb_to_hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// All components are in the range [0 ... 1], including hue.
vec3 hsv_to_rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    vec3 tex_hsv = rgb_to_hsv(tex_color.rgb);

    // x HUE (0 = 0, 1.0 = 360 degrees)
    // y SATURATION
    // z LUMINANCE
    if(tex_hsv.x >= _min && tex_hsv.x <= _max) {
        vec3 new_color_hsv = rgb_to_hsv(new_color.rgb);
        tex_hsv.x = new_color_hsv.x;
        tex_hsv.y = tex_hsv.y * new_color_hsv.y;
        tex_color.rgb = hsv_to_rgb(tex_hsv) * new_color_hsv.z;
    }

    COLOR = tex_color;
}
