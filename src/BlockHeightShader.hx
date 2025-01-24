import hxsl.Shader;

class BlockHeightShader extends Shader {
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

				// normalize the height so we can see it easier
				var h = (float(baseHeight) / 5.) + (raw.r * 5.);

				pixelColor = vec4(h, h, h, raw.a);
			}
		}
	};
}
