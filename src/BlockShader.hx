import hxsl.Shader;

class BlockShader extends Shader {
	static var SRC = {
		@input var input:{
			var position:Vec2;
			var uv:Vec2;
			var color:Vec4;
		};
		var pixelColor:Vec4;
		var outputPosition:Vec4;
		@param var sceneHeightTexture:Sampler2D;
		@param var enabled:Int = 1; // can't use Bool here for some reason
		function fragment() {
			if (enabled == 1) {
				var screenUv = outputPosition.xy % 1.;
				var h = sceneHeightTexture.get(screenUv).r; // not outputting expected color

				// eventually want to read data outside from the screenHeightTexture of the tile x/y so we can draw outlines based on height differences
				pixelColor = vec4(h, screenUv.y, h, pixelColor.a);
			}
		}
	};
}
