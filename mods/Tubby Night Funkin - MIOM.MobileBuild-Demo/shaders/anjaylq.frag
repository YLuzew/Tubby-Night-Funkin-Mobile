#pragma header

#define quality 12

uniform float radius; // 0.05
uniform float strength; // 1.0
uniform vec2 offset;

void main() {
	vec2 uv = openfl_TextureCoordv;
	vec4 color = flixel_texture2D(bitmap, uv);

	if (strength != 0.0) {
		int q = int(max(min(float(quality), radius * 128.0), 1.0));

		uv.xy -= 0.5;

		float rstep = -radius / float(q) + 1.0;
		float sstep = strength / q;
		for (int i = 0;i<q;i++) {
			uv = uv * rstep + offset;
			color += flixel_texture2D(bitmap, uv + vec2(0.5, 0.5)) * sstep;
		}
	}
	gl_FragColor = color;
}