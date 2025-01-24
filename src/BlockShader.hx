import hxsl.Shader;

/**
 * Eventually want to read screenHeightTexture data around current tile so we can draw outlines based on height differences
 * between neighboring blocks. (like a depth texture)
 */
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
			pixelColor.g = 1;
			pixelColor.a = 1;
			// var screenUv = outputPosition.xy % 1.;
			// var h = sceneHeightTexture.get(screenUv).r;

			// Unsure how to actually go about reading from the larger scene height texture
			// This is currently not outputting the expected color
			// pixelColor = vec4(h, screenUv.y, h, pixelColor.a);
		}
	};
}
