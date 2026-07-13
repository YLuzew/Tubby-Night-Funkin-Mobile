#pragma header

#import <postprocess.frag>

uniform float uScale;
uniform float uIntensity;
uniform float uTime;
uniform bool uSpriteMode;
uniform vec3 uRainColor;

mediump float hash(mediump vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
	mediump float intensityMix = mix(1.0, 0.1, uIntensity);
	mediump float invScale = 1.0 / uScale;
	mediump vec2 offsetFactor = vec2(10.0, -2.0) * uScale;

	mediump vec2 wpos = uSpriteMode ? screenToWorld(screenToFrame(openfl_TextureCoordv))
	                                : screenToWorld(screenCoord);
	mediump vec2 origWpos = wpos;

	mediump vec3 add = vec3(0.0);
	mediump float rainSum = 0.0;

	{
		mediump vec2 p = wpos * invScale;
		p *= 0.1;
		p.x += p.y * 0.1;
		p.y -= uTime * 500.0;
		p.y *= 0.03;
		mediump float ix = floor(p.x);
		p.y += mod(ix, 2.0) * 0.5 + (fract(ix * 0.61803398875 + 0.38196601125) - 0.5) * 0.3;
		mediump float iy = floor(p.y);
		mediump vec2 index = vec2(ix, iy);
		mediump float h = hash(index);
		p -= index;
		p.x += (fract(h * 83.456) * 2.0 - 1.0) * 0.35;
		mediump vec2 a = abs(p - 0.5);
		mediump float res = max(a.x * 0.8, a.y * 0.5) - 0.1;
		bool empty = h < intensityMix;
		mediump float r = empty ? 1.0 : res;
		if (r < 0.0) {
			mediump float t = r * 5.0;
			mediump float v = (-t - 0.5*t*t) * 2.0;
			wpos += v * offsetFactor;
			add += vec3(0.1, 0.15, 0.2) * v;
			rainSum += (1.0 - rainSum) * 0.75;
		}
	}

	{
		mediump vec2 p = wpos * (1.8 * invScale) + 500.0;
		p *= 0.1;
		p.x += p.y * 0.1;
		p.y -= uTime * 277.7778;
		p.y *= 0.03;
		mediump float ix = floor(p.x);
		p.y += mod(ix, 2.0) * 0.5 + (fract(ix * 0.61803398875 + 0.38196601125) - 0.5) * 0.3;
		mediump float iy = floor(p.y);
		mediump vec2 index = vec2(ix, iy);
		mediump float h = hash(index);
		p -= index;
		p.x += (fract(h * 83.456) * 2.0 - 1.0) * 0.35;
		mediump vec2 a = abs(p - 0.5);
		mediump float res = max(a.x * 0.8, a.y * 0.5) - 0.1;
		bool empty = h < intensityMix;
		mediump float r = empty ? 1.0 : res;
		if (r < 0.0) {
			mediump float t = r * 5.0;
			mediump float v = (-t - 0.5*t*t) / 1.8 * 2.0;
			wpos += v * offsetFactor;
			add += vec3(0.1, 0.15, 0.2) * v;
			rainSum += (1.0 - rainSum) * 0.75;
		}
	}

	{
		mediump vec2 p = wpos * (2.6 * invScale) + 1000.0;
		p *= 0.1;
		p.x += p.y * 0.1;
		p.y -= uTime * 192.3077;
		p.y *= 0.03;
		mediump float ix = floor(p.x);
		p.y += mod(ix, 2.0) * 0.5 + (fract(ix * 0.61803398875 + 0.38196601125) - 0.5) * 0.3;
		mediump float iy = floor(p.y);
		mediump vec2 index = vec2(ix, iy);
		mediump float h = hash(index);
		p -= index;
		p.x += (fract(h * 83.456) * 2.0 - 1.0) * 0.35;
		mediump vec2 a = abs(p - 0.5);
		mediump float res = max(a.x * 0.8, a.y * 0.5) - 0.1;
		bool empty = h < intensityMix;
		mediump float r = empty ? 1.0 : res;
		if (r < 0.0) {
			mediump float t = r * 5.0;
			mediump float v = (-t - 0.5*t*t) / 2.6 * 2.0;
			wpos += v * offsetFactor;
			add += vec3(0.1, 0.15, 0.2) * v;
			rainSum += (1.0 - rainSum) * 0.75;
		}
	}

	{
		mediump vec2 p = wpos * (4.8 * invScale) + 1500.0;
		p *= 0.1;
		p.x += p.y * 0.1;
		p.y -= uTime * 104.1667;
		p.y *= 0.03;
		mediump float ix = floor(p.x);
		p.y += mod(ix, 2.0) * 0.5 + (fract(ix * 0.61803398875 + 0.38196601125) - 0.5) * 0.3;
		mediump float iy = floor(p.y);
		mediump vec2 index = vec2(ix, iy);
		mediump float h = hash(index);
		p -= index;
		p.x += (fract(h * 83.456) * 2.0 - 1.0) * 0.35;
		mediump vec2 a = abs(p - 0.5);
		mediump float res = max(a.x * 0.8, a.y * 0.5) - 0.1;
		bool empty = h < intensityMix;
		mediump float r = empty ? 1.0 : res;
		if (r < 0.0) {
			mediump float t = r * 5.0;
			mediump float v = (-t - 0.5*t*t) / 4.8 * 2.0;
			wpos += v * offsetFactor;
			add += vec3(0.1, 0.15, 0.2) * v;
			rainSum += (1.0 - rainSum) * 0.75;
		}
	}

	mediump vec3 color;
	lowp float alpha;
	if (uSpriteMode) {
		mediump vec2 rwpos = worldToScreen(wpos - origWpos);
		lowp vec4 data = flixel_texture2D(bitmap, openfl_TextureCoordv + rwpos);
		color = data.xyz;
		alpha = data.w;
	} else {
		lowp vec4 data = flixel_texture2D(bitmap, worldToScreen(wpos));
		color = data.xyz;
		alpha = data.w;
	}

	color += add;
	color = mix(color, uRainColor, 0.1 * rainSum);
	gl_FragColor = vec4(color, alpha);
}