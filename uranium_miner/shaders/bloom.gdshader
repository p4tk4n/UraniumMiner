shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.5, 0.2, 1.0);
uniform float glow_intensity : hint_range(0.0, 5.0) = 1.0;
uniform float glow_radius : hint_range(0.0, 1.0) = 0.05; // Controls bloom size
uniform float pulse_speed : hint_range(0.0, 5.0) = 2.0;
uniform float pulse_strength : hint_range(0.0, 1.0) = 0.3;

void fragment() {
    vec4 original = texture(TEXTURE, UV);
    
    // Pulsing effect
    float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
    float current_intensity = glow_intensity * (1.0 + pulse * pulse_strength);
    float current_radius = glow_radius * (1.0 + pulse * pulse_strength * 0.5);
    
    vec3 glow = vec3(0.0);
    
    if (original.a == 0.0) {
        // Sample multiple rings around the sprite
        for (int ring = 1; ring <= 3; ring++) {
            float ring_radius = current_radius * (float(ring) / 3.0);
            
            for (float angle = 0.0; angle < 6.283; angle += 1.57) { // 4 samples per ring
                vec2 offset = vec2(cos(angle), sin(angle)) * ring_radius;
                vec4 sampled = texture(TEXTURE, UV + offset);
                
                if (sampled.a > 0.0) {
                    // Stronger glow for closer distances
                    float strength = 1.0 - (float(ring) / 3.0);
                    glow += glow_color.rgb * current_intensity * strength;
                }
            }
        }
        
        glow /= 12.0; // Average the samples (3 rings × 4 samples)
    }
    
    COLOR.rgb = original.rgb + glow;
    COLOR.a = max(original.a, length(glow));
}
