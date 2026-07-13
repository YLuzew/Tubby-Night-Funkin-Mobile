#pragma header

uniform float intensity;

void main() {
    if (intensity <= 0.0) {
        gl_FragColor = vec4(0.0);
        return;
    }

    vec2 uv = openfl_TextureCoordv;
    float dist = distance(uv, vec2(0.5));
    float exponent = 6.0 / (intensity * 2.0 + 0.1);
    float glow = exp(-dist * exponent) * intensity;
    vec3 cyan = vec3(0.0, 1.0, 1.0);

    gl_FragColor = vec4(cyan * glow, glow);
}