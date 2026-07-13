#pragma header

uniform float yRot;

void main() {
    float rad = radians(yRot);
    
    vec2 uv = openfl_TextureCoordv - 0.5;

    float perspective = 0.5; 

    float rotCos = cos(rad);
    float rotSin = sin(rad);

    float dist = 1.0 + uv.x * rotSin * perspective;
    
    uv.x /= rotCos;
    uv.y /= dist;
    
    uv /= (1.0 + perspective * 0.1);

    uv += 0.5;

    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        discard;
    } else {
        gl_FragColor = flixel_texture2D(bitmap, uv);
    }
}