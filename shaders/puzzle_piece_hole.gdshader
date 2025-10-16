shader_type canvas_item;

uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.5); // Color of the inner shadow (black, 50% opaque)
uniform vec4 base_color : source_color = vec4(0.0, 0.0, 0.0, 0.5); // Color of the inner shadow (black, 50% opaque)
uniform float shadow_distance = 0.01; // How far the shadow extends inwards (in UV space, 0 to 1)
uniform float shadow_softness = 0.5;  // How soft the shadow edge is (0.0 = hard, 1.0 = very soft)
uniform float global_alpha : hint_range(0.0, 1.0) = 1.0; // New uniform for global alpha control
uniform vec2 shadow_offset = vec2(0.01, 0.01); // Direction and intensity of the shadow offset (in UV space)

uniform float cutout_threshold = 0.1; // Alpha threshold to determine if a pixel is part of the shape or transparent

void fragment() {
    // Get the current pixel's color from the sprite's main texture (this defines your shape)
    vec4 current_pixel_color = texture(TEXTURE, UV);
    float current_alpha = current_pixel_color.a;

    // Determine if the current pixel is part of the "shape"
    bool is_in_shape = current_alpha > cutout_threshold;

    // --- Inner Shadow Logic ---
    vec4 final_color_with_shadow = base_color * current_pixel_color.a; // Start with the original color

    if (is_in_shape) {
        // Sample a pixel slightly outside the shape in the opposite direction of the shadow_offset
        // This is done to find the *edge* from the perspective of the shadow.
        // We move UV by a small amount *against* the shadow_offset direction.
        vec2 sample_uv_outside = UV - (shadow_offset * shadow_distance);

        // Get the alpha of the pixel that's 'outside'
        float outside_alpha = texture(TEXTURE, sample_uv_outside).a;

        // Calculate the "shadow factor" based on how close we are to the edge of the shape
        // and how much the outside pixel is transparent.
        // If outside_alpha is low (transparent), it means we are near the edge.
        // We use smoothstep to create a soft falloff for the shadow.
        float edge_intensity = 1.0 - smoothstep(cutout_threshold, cutout_threshold + shadow_softness, outside_alpha);

        // Apply the shadow color based on the edge intensity
        final_color_with_shadow = mix(final_color_with_shadow, shadow_color, shadow_color.a * edge_intensity);
    }

    // --- Apply Global Alpha ---
    // The final alpha for the pixel should be the original sprite's alpha (current_alpha)
    // multiplied by the global_alpha uniform.
    // We also need to ensure the shadow's alpha is considered in final_color_with_shadow.a
    // before applying the global_alpha.

    // Combine the original alpha with the shadow's alpha (if any)
    // The mix operation already handles the alpha of the shadow_color.
    // So, final_color_with_shadow.a already contains the combined alpha from the original pixel
    // and the shadow.
    float combined_alpha = final_color_with_shadow.a;

    // Now, apply the global alpha to this combined alpha.
    float output_alpha = combined_alpha * global_alpha;

    // Set the final color and alpha for the pixel.
    COLOR = vec4(final_color_with_shadow.rgb, output_alpha);
}