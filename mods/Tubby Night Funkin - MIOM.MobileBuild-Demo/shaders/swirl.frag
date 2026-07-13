#pragma header

uniform float iTime;
uniform vec2 uMouse;
uniform float uIntensity;
uniform float uHue;

const mat2 uvShift = mat2(6.0, -8.0, 8.0, 6.0) / 8.0;

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float fluidNoise(vec2 uv, float time) {
    vec2 p = uv;
    for (float i = 0.0; i < 5.0; i++) {
        p.x += sin(p.y + i + time * 0.2);
        p *= uvShift;
        p += vec2(sin(time * 0.1), cos(time * 0.05));
    }
    return sin(p.x + p.y);
}

void main() {
    vec2 uv = openfl_TextureCoordv;
    
    float largeShape = fluidNoise(uv * 1.5, iTime * 0.15);
    float fineDetail = fluidNoise(uv * 9.0, iTime * 0.3);
    
    float combinedNoise = fineDetail + (largeShape * 1.8);
    
    float lineCount = 120.0;
    float lineNoise = sin(uv.y * lineCount + combinedNoise * 2.0);
    
    float mask = smoothstep(0.0, 0.15, lineNoise);

    vec3 deepBase = hsv2rgb(vec3(uHue, 1.0, 0.15));
    vec3 mainColor = hsv2rgb(vec3(uHue, 0.8, 1.0));
    vec3 secondaryColor = hsv2rgb(vec3(uHue + 0.12, 0.7, 0.9));

    vec3 dynamicColor = mix(mainColor, secondaryColor, largeShape * 0.5 + 0.5);
    vec3 finalColor = mix(deepBase, dynamicColor, mask);
    
    gl_FragColor = vec4(finalColor, 1.0) * openfl_Alphav;
}