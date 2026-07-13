#pragma header

uniform float intensity;

void main() {
    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

    if (intensity <= 0.0) {
        gl_FragColor = color;
        return;
    }

    vec3 cyan = vec3(0.0, 1.0, 1.0);
    float boost = intensity * 3.5;
    color.rgb += cyan * boost * color.a;

    gl_FragColor = color;
}