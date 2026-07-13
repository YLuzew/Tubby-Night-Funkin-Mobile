#pragma header

#define MAX_SAMPLES 6

uniform float radius;   // 0.05
uniform float strength; // 1.0
uniform vec2 offset;

void main() {
    vec2 uv = openfl_TextureCoordv;
    vec4 color = flixel_texture2D(bitmap, uv);

    if (strength != 0.0) {
        
        int q = int(min(MAX_SAMPLES, max(1.0, radius * 32.0)));
        
        uv.xy -= 0.5;
        

        float rstep = 1.0 - (radius / float(q));
        float sstep = strength / float(q);
        
        for (int i = 0; i < MAX_SAMPLES; i++) {
            if (i >= q) break;
            uv = uv * rstep + offset;
            color += flixel_texture2D(bitmap, uv + vec2(0.5, 0.5)) * sstep;
        }
    }
    gl_FragColor = color;
}