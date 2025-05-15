shader_type canvas_item;

uniform float vignette_strength : hint_range(0.0, 1.0) = 0.5;
uniform float vignette_inner : hint_range(0.0, 1.0) = 0.3;
uniform float vignette_outer : hint_range(0.0, 1.0) = 0.8;
uniform vec3 vignette_color : source_color = vec3(0.0);

uniform float noise_amount : hint_range(0.0, 1.0) = 0.05;
uniform float grain_size : hint_range(0.0, 10.0) = 2.0;
uniform float grain_velocity : hint_range(0.0, 1.0) = 0.05;
uniform vec3 grain_color : source_color = vec3(0.2);

uniform float brightness : hint_range(-1.0, 1.0) = 0.0;
uniform float contrast : hint_range(0.0, 2.0) = 1.0;
uniform vec3 sepia_tone : source_color = vec3(1.2, 1.0, 0.82); // Light sepia

uniform sampler2D screen_texture:hint_screen_texture,repeat_disable,filter_nearest;

// Simple random function
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;
    vec3 color = texture(screen_texture,SCREEN_UV).rgb;

    // 1. Vignette
    float dist = length(uv - 0.5);
    float vignette = 1.0 - smoothstep(vignette_outer, vignette_inner, dist);
    color = mix(color, vignette_color, vignette * vignette_strength);

    // 3. Noise/Grain
    vec2 grain_uv = uv * SCREEN_PIXEL_SIZE * grain_size;
    float random_value = rand(grain_uv + TIME * grain_velocity);
    vec3 grain = (random_value - 0.5) * noise_amount * grain_color;
    color += grain;

    // 4. Brightness and Contrast
    color += brightness;
    color = (color - 0.5) * contrast + 0.5;

    // 5. Sepia Tone (applied after brightness/contrast for better control)
    color = mix(color, vec3(dot(color, vec3(0.299, 0.587, 0.114))), 0.2); // Desaturate a bit
    color = mix(color, sepia_tone, 0.15);

    COLOR.rgb = clamp(color, 0.0, 1.0);
    COLOR.a = texture(TEXTURE, uv).a; // Keep the original alpha
}