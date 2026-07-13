#pragma header

uniform vec4 uFrameBounds;
uniform float ang;
uniform float dist;
uniform float str;
uniform float thr;
uniform float angOffset;
uniform sampler2D altMask;
uniform bool useMask;
uniform float thr2;
uniform vec3 dropColor;
uniform float hue;
uniform float saturation;
uniform float brightness;
uniform float contrast;
uniform float zoom;
uniform bool pixelPerfect;
uniform bool flipX;
uniform bool flipY;

const vec3 grayscaleValues = vec3(0.3098039215686275, 0.607843137254902, 0.0823529411764706);
const vec3 intensityWeights = vec3(0.3098, 0.6078, 0.0823);
const float e = 2.718281828459045;

vec3 applyHSBCEffect(vec3 color) {
    color = color + (brightness / 255.0);

    float angle = radians(hue);
    float c = cos(angle);
    float s = sin(angle);
    mat3 m = mat3(
        0.213 + 0.787*c - 0.213*s, 0.213 - 0.213*c + 0.143*s, 0.213 - 0.213*c - 0.787*s,
        0.715 - 0.715*c - 0.715*s, 0.715 + 0.285*c + 0.140*s, 0.715 - 0.715*c + 0.715*s,
        0.072 - 0.072*c + 0.928*s, 0.072 - 0.072*c - 0.283*s, 0.072 + 0.928*c + 0.072*s
    );
    color = m * color;

    float contVal = 1.0 + (contrast / 100.0);
    if (contVal > 1.0) {
        contVal = (((0.00852259 * pow(e, 4.76454 * (contVal - 1.0))) * 1.01) - 0.0086078159) * 10.0 + 1.0;
    }
    color = clamp((color - 0.25) * contVal + 0.25, 0.0, 1.0);

    float satVal = saturation;
    if (satVal > 0.0) satVal = satVal * 3.0;
    satVal = 1.0 + (satVal / 100.0);
    vec3 gray = vec3(dot(color, grayscaleValues));
    color = clamp(mix(gray, color, satVal), 0.0, 1.0);

    return color;
}

void main() {
    vec4 col = texture2D(bitmap, openfl_TextureCoordv);

    if (col.a == 0.0) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    }

    vec3 outColor = col.a < 1.0 ? col.rgb / col.a : col.rgb;
    outColor = applyHSBCEffect(outColor);

    float intensity = dot(col.rgb, intensityWeights);
    float maskVal = 0.0;
    if (useMask) {
        maskVal = texture2D(altMask, openfl_TextureCoordv).b;
    }
    float threshold = (maskVal > 0.0) ? thr2 : thr;
    float edge = 1.5 / openfl_TextureSize.x;
    intensity = smoothstep(threshold - edge, threshold + edge, intensity);

    if (str > 0.0 && (dist > 0.0 || angOffset != 0.0)) {
        vec2 offset = vec2(dist * zoom, 0.0);
        float angTotal = ang + angOffset;
        offset = vec2(offset.x * cos(angTotal), -offset.x * sin(angTotal));
        if (flipX) offset.x = -offset.x;
        if (flipY) offset.y = -offset.y;
        if (pixelPerfect) offset = floor(offset + 0.5);

        vec2 checkedPixel = openfl_TextureCoordv + offset / openfl_TextureSize;
        float dropAlpha = 0.0;
        if (checkedPixel.x > uFrameBounds.x && checkedPixel.y > uFrameBounds.y &&
            checkedPixel.x < uFrameBounds.z && checkedPixel.y < uFrameBounds.w) {
            dropAlpha = texture2D(bitmap, checkedPixel).a;
        }

        vec3 shadowContribution = dropColor.rgb * (1.0 - dropAlpha * str) * intensity;
        outColor = outColor + shadowContribution;
    }

    gl_FragColor = vec4(outColor.rgb * col.a, col.a);
}