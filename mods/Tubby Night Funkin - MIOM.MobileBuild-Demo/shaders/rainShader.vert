#pragma header

varying vec2 screenCoord;

void main() {
	#pragma body

	screenCoord = openfl_TextureCoord;
}