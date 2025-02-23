shader_type spatial;
render_mode unshaded;

uniform float base_scale = 2.0;  // Zoom initial
uniform float zoom_intensity = 1.5; // Amplitude du zoom
uniform float zoom_speed = 0.5; // Vitesse du zoom
uniform float speed = 0.5;  // Vitesse de l'animation
uniform int iterations = 20; // Nombre d'itérations fractales
uniform vec3 color1 = vec3(1.0, 0.0, 0.0); // Rouge sang
uniform vec3 color2 = vec3(0.0, 0.0, 1.0); // Bleu électrique
uniform float warp_intensity = 0.3; // Distorsion temporelle
uniform float rotation_speed = 0.2; // Rotation fractale
uniform float chromatic_strength = 0.05; // Intensité du glitch RGB
uniform float wave_intensity = 0.1; // Amplitude des ondes de perturbation

// Fonction fractale type Mandelbulb 2D
float mandelbulb(vec2 uv) {
    vec2 c = uv;
    vec2 z = vec2(0.0);
    float iter = 0.0;
    
    for (int i = 0; i < iterations; i++) {
        float theta = atan(z.y, z.x) * 2.0; // Déformation angulaire
        float radius = length(z) * 1.2; // Expansion exponentielle
        z = vec2(cos(theta) * radius, sin(theta) * radius) + c;
        
        if (length(z) > 4.0) break;
        iter += 1.0;
    }
    
    return iter / float(iterations);
}

// Fonction de rotation
vec2 rotate(vec2 uv, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return vec2(uv.x * c - uv.y * s, uv.x * s + uv.y * c);
}

// Effet de décalage chromatique (Glitch RGB)
vec3 chromatic_aberration(vec2 uv) {
    float offset = chromatic_strength * sin(TIME * 2.0);
    float r = mandelbulb(uv + vec2(offset, 0.0));
    float g = mandelbulb(uv);
    float b = mandelbulb(uv - vec2(offset, 0.0));
    return vec3(r, g, b);
}

// Fonction principale du shader
void fragment() {
    float zoom_factor = 1.0 + sin(TIME * zoom_speed) * zoom_intensity; // Zoom cyclique
    vec2 uv = normalize(VERTEX).xy * (base_scale / zoom_factor);  // Mapping sphérique avec zoom dynamique
    
    // Rotation de l’espace UV
    float angle = TIME * rotation_speed;
    uv = rotate(uv, angle);
    
    // Ajout d'ondes de perturbation
    uv.x += sin(TIME * speed * 6.0 + uv.y * 5.0) * wave_intensity;
    uv.y += cos(TIME * speed * 6.0 + uv.x * 5.0) * wave_intensity;
    
    // Ajout de distorsion temporelle ondulante
    uv.x += sin(TIME * speed * 8.0) * warp_intensity;
    uv.y += cos(TIME * speed * 8.0) * warp_intensity;
    
    // Effet miroir pour une symétrie fractale hypnotisante
    uv = abs(fract(uv) - 0.5);
    
    // Appliquer l'effet RGB glitch
    vec3 final_color = chromatic_aberration(uv);

    // Ajout d’un effet de pulsation chromatique
    final_color *= sin(TIME * 1.5) * 0.5 + 0.5;
    
    ALBEDO = final_color;
}
