shader_type canvas_item;
render_mode blend_mix;

uniform vec4 base_color : source_color;
uniform float location_fade : hint_range(0.0, 1.0) = 1.0;
uniform float thickness : hint_range(0.0, 3.0) = 1.5;

// Light mask texture from SubViewport
uniform sampler2D light_mask : hint_default_black;
uniform float light_clear_intensity : hint_range(0.0, 2.0) = 0.8; // How much fog light removes
uniform float light_falloff : hint_range(0, 5.0) = 1.5; // Smooth curve for influence

void fragment() {
    // --- Sample fog texture multiple times for movement ---
    vec3 fog_color_1 = texture(TEXTURE, vec2(UV.x / 2.0 + TIME / 100.0, UV.y / 4.0 - TIME / 100.0)).rgb;
    vec3 fog_color_2 = texture(TEXTURE, vec2(UV.x / 2.0 + 0.5 + TIME / 50.0, UV.y / 4.0 + 0.5 - TIME / 160.0)).rgb;
    vec3 fog_color_3 = texture(TEXTURE, vec2(UV.x / 2.0 + 0.25 + TIME / 25.0, UV.y / 4.0 - 0.25 + TIME / 160.0)).rgb;

    // Mix fog layers
    vec3 fog_color = mix(fog_color_3, mix(fog_color_1, fog_color_2, 0.5), 0.7);

    // --- Sample the light mask ---
    float light_amount = texture(light_mask, UV).r;

    // Apply falloff for smoother fading
    light_amount = pow(light_amount, light_falloff);

    // --- Aggressive thinning ---
    float aggressive_light = pow(light_amount, 2.0); // emphasize bright areas more
    float local_thickness = thickness * (1.0 - aggressive_light * light_clear_intensity * 1.5);

    // Clamp to avoid negative thickness
    local_thickness = max(local_thickness, 0.0);

    // --- Final fog alpha ---
    float fog_alpha = base_color.a * fog_color.r * local_thickness;

    // --- Output ---
    COLOR.rgb = fog_color * base_color.rgb * location_fade;
    COLOR.a = fog_alpha;
}
