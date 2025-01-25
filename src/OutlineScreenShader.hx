import h3d.shader.ScreenShader;

/**
 * Use height texture to render an outline
 */
class OutlineScreenShader extends ScreenShader {
	static var SRC = {
		@param var texture:Sampler2D;
		@param var heightTexture:Sampler2D;
		@param var pad:Vec2;
		function fragment() {
			var raw = heightTexture.get(input.uv);
			var px = texture.get(input.uv);

			var current = raw.r;
			var above = heightTexture.get(input.uv - vec2(0, pad.y)).r;
			var below = heightTexture.get(input.uv - vec2(0, -pad.y)).r;
			var left = heightTexture.get(input.uv - vec2(pad.x, 0)).r;
			var right = heightTexture.get(input.uv - vec2(-pad.x, 0)).r;

			var dif = .035;

			var outlineColor = vec4(0, 0, 0, 1);

			if (above.r - current > dif || below.r - current > dif || left.r - current > dif || right.r - current > dif) {
				pixelColor.rgba = mix(px, outlineColor, outlineColor.a);
			} else {
				pixelColor = px;
			}
		}
	};
}
