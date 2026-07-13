#pragma header

const float amount = 0.0;
const float dim = 1.8;
const float Directions = 16.0;
const float Quality = 8.0;
const float Size = 10.0;

const float brightness = 1.5;

void main(void)
{
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 texSize = openfl_TextureSize.xy;
    
    vec2 step = 1.0 / texSize;
    vec4 blurredCenter = vec4(0.0);
    blurredCenter += texture2D(bitmap, uv + vec2(-step.x,  step.y)) * 0.0625;
    blurredCenter += texture2D(bitmap, uv + vec2( 0.0,     step.y)) * 0.125;
    blurredCenter += texture2D(bitmap, uv + vec2( step.x,  step.y)) * 0.0625;
    blurredCenter += texture2D(bitmap, uv + vec2(-step.x,  0.0   )) * 0.125;
    blurredCenter += texture2D(bitmap, uv)                      * 0.25;
    blurredCenter += texture2D(bitmap, uv + vec2( step.x,  0.0   )) * 0.125;
    blurredCenter += texture2D(bitmap, uv + vec2(-step.x, -step.y)) * 0.0625;
    blurredCenter += texture2D(bitmap, uv + vec2( 0.0,    -step.y)) * 0.125;
    blurredCenter += texture2D(bitmap, uv + vec2( step.x, -step.y)) * 0.0625;
    
    vec4 center = blurredCenter;

    float totalSamples = Directions * Quality;
    float goldenAngle = 2.399963;
    const int SAMPLE_COUNT = 12;
    float scale = totalSamples / float(SAMPLE_COUNT);
    float minRadius = 1.0 / max(Quality, 1.0);

    vec4 sumColor = center;

    for (int i = 0; i < 12; i++)
    {
        if (i >= SAMPLE_COUNT) break;

        float n = float(i) + 0.5;
        float t = sqrt(n / float(SAMPLE_COUNT));
        float radius = Size * (minRadius + (1.0 - minRadius) * t);
        float angle = n * goldenAngle;
        vec2 offset = vec2(cos(angle), sin(angle)) * radius;
        vec2 sampleUv = uv + offset / texSize;
        sumColor += texture2D(bitmap, sampleUv) * scale;
    }

    float divisor = dim * totalSamples - 15.0;
    vec4 Color = sumColor / divisor;

    const float compensate = 7.5 / 20.0;
    vec4 bloom = (center / dim) + Color * compensate;

    gl_FragColor = bloom * brightness;
}