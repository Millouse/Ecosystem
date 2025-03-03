shader_type spatial;
render_mode unshaded;

uniform int max_iter = 200;
uniform float zoom = 1.0;
uniform float rotation_speed = 0.2;

// Fonction de rotation
vec2 rotate(vec2 uv, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return vec2(uv.x * c - uv.y * s, uv.x * s + uv.y * c);
}

void fragment() {
    float angle = TIME * rotation_speed;
    vec2 uv = UV * 4.0 - vec2(2.0, 2.0);

    uv = rotate(uv, angle);

    vec2 c = uv / zoom;
    vec2 z = vec2(0.0);
    int iter = 0;

    while (length(z) < 2.0 && iter < max_iter) {
        float x = z.x * z.x - z.y * z.y + c.x;
        float y = 2.0 * z.x * z.y + c.y;
        z = vec2(x, y);
        iter++;
    }

    float color = float(iter) / float(max_iter);
    ALBEDO = vec3(color);
}