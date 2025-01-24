import h3d.shader.ScreenShader;
import hxsl.Shader;

class HeightScreenShader extends ScreenShader {
	static var SRC = {
		@param var heightTexture:Sampler2D;
		@param var baseHeight:Int;
		function fragment() {
			var raw = heightTexture.get(input.uv);
			var h = (baseHeight * .2) + (raw.r * 5); // normalize the height so we can see it easier

			pixelColor = vec4(h, h, h, raw.a);
		}
	};
}

/**
 * This shader seems to output everything at the right spot with no issues, but it's not a ScreenShader, so it cannot be used in a filter
 */
class HeightShader extends Shader {
	static var SRC = {
		@input var input:{
			var position:Vec2;
			var uv:Vec2;
			var color:Vec4;
		};
		var pixelColor:Vec4;
		@param var heightTexture:Sampler2D;
		@param var baseHeight:Int;
		@param var enabled:Int = 1;
		function fragment() {
			if (enabled == 1) {
				var raw = heightTexture.get(input.uv);
				var h = (baseHeight * .2) + (raw.r * 5); // normalize the height so we can see it easier

				pixelColor = vec4(h, h, h, raw.a);
			}
		}
	};
}
