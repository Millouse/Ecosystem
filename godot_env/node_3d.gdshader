shader_type spatial;
render_mode unshaded;

uniform int max_iter = 1000;
uniform float zoom = 1.0;
uniform float speed = 0.1;  // Facteur de vitesse pour l'animation

void fragment() {
    // Déplacer les coordonnées complexes sur le temps pour l'animation
    vec2 uv = UV * 4.0 - vec2(2.0, 2.0);  // Ajuster l’échelle
    vec2 c = uv / zoom;

    // Déplacer les coordonnées complexes avec le temps (animation)
    c.x += sin(TIME * speed) * 0.5;  // Mouvement horizontal
    c.y += cos(TIME * speed) * 0.5;  // Mouvement vertical

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
