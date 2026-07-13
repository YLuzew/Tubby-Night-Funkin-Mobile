#pragma header

uniform float blurAmount;
uniform int blurRadius;  

void main() {
    vec2 uv = openfl_TextureCoordv;
    vec2 texSize = openfl_TextureSize.xy;

    if (blurAmount < 0.0001) {
        gl_FragColor = flixel_texture2D(bitmap, uv);
        return;
    }

    float sigma = blurAmount * 0.45;
    float twoSigma2 = 2.0 * sigma * sigma;
    float invTwoSigma2 = 1.0 / twoSigma2;

    vec4 color = flixel_texture2D(bitmap, uv);
    float totalWeight = 1.0;


    for (int i = 1; i <= blurRadius; i++) {
        float weight = exp(-float(i * i) * invTwoSigma2);
        vec2 offset = vec2(blurAmount * float(i) / texSize.x, 0.0);
        color += flixel_texture2D(bitmap, uv + offset) * weight;
        color += flixel_texture2D(bitmap, uv - offset) * weight;
        totalWeight += weight * 2.0;
    }

    
    for (int i = 1; i <= blurRadius; i++) {
        float weight = exp(-float(i * i) * invTwoSigma2);
        vec2 offset = vec2(0.0, blurAmount * float(i) / texSize.y);
        color += flixel_texture2D(bitmap, uv + offset) * weight;
        color += flixel_texture2D(bitmap, uv - offset) * weight;
        totalWeight += weight * 2.0;
    }

    gl_FragColor = color / totalWeight;
}