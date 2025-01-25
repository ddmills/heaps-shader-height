import h2d.Bitmap;
import h2d.Tile;
import h2d.filter.Shader;
import hxd.Key;
import hxd.Window;
import hxsl.Types.Texture;
import hxsl.Types.Vec;

typedef Block = {
	heightShader:BlockHeightShader,
	bitmap:Bitmap,
}

class Main extends hxd.App {
	var sceneHeightTexture:Texture;
	var overlay:Bitmap;
	var blocks:Array<Block> = [];

	static function main() {
		new Main();
		hxd.Res.initLocal();
	}

	override function init() {
		s2d.renderer.globals.set("renderHeight", false);

		engine.backgroundColor = 0x206980;
		var window = Window.getInstance();

		// create a new texture to render height data into
		sceneHeightTexture = new Texture(window.width, window.height, [Target]);
		sceneHeightTexture.filter = Nearest;
		sceneHeightTexture.clear(0);

		// renders black outline using the height texture
		var outline = new OutlineScreenShader();

		var pad = 2;

		outline.pad = new Vec((1 / window.width) * pad, (1 / window.height) * pad);
		outline.heightTexture = sceneHeightTexture;
		s2d.filter = new Shader<OutlineScreenShader>(outline);

		// fix texture size when window is resized
		window.addResizeEvent(() -> {
			sceneHeightTexture.resize(window.width, window.height);
			outline.pad = new Vec((1 / window.width) * pad, (1 / window.height) * pad);
		});

		// populate scene
		makeblock(100, 100, 0);
		makeblock(200, 100, 0);
		makeblock(300, 100, 0);
		makeblock(400, 100, 0);

		makeblock(150, 50, 1);
		makeblock(250, 50, 1);
		makeblock(350, 50, 1);

		makeblock(200, 0, 2);
		makeblock(300, 0, 2);

		makeblock(250, -50, 3);

		makeblock(150, 125, 0);
		makeblock(150, 100, 1);
		makeblock(150, 75, 2);

		makeblock(450, 125, 0);
		makeblock(450, 100, 1);
		makeblock(450, 75, 2);
		makeblock(450, 50, 3);
		makeblock(450, 25, 4);

		makeblock(350, 425, 0);
		makeblock(350, 400, 1);
		makeblock(350, 375, 2);

		overlay = new Bitmap(Tile.fromTexture(sceneHeightTexture), s2d);
	}

	override function update(dt:Float) {
		sceneHeightTexture.clear(0);
		// hide overlay so it doesn't render itself
		overlay.visible = false;
		s2d.filter.enable = false;

		// render to texture (size of screen)
		s2d.renderer.globals.set("renderHeight", 1);
		s2d.drawTo(sceneHeightTexture);
		s2d.renderer.globals.set("renderHeight", 0);

		// toggle showing scene height texture with SPACE key
		overlay.visible = hxd.Key.isDown(Key.SPACE);
		s2d.filter.enable = !overlay.visible;
	}

	function makeblock(x:Int, y:Int, z:Int):Block {
		var bm = new Bitmap(hxd.Res.block.toTile(), s2d);
		bm.width = 100;
		bm.height = 100;
		bm.x = x;
		bm.y = y;

		// var blockShader = new BlockShader();
		// blockShader.enabled = 1;
		// blockShader.sceneHeightTexture = sceneHeightTexture; // want to use scene height texture as input to the block shader
		// bm.addShader(blockShader);
		// blockShaders.push(blockShader);

		var heightShader = new BlockHeightShader();
		heightShader.baseHeight = z;
		heightShader.heightTexture = hxd.Res.block_height.toTexture();
		heightShader.heightTexture.filter = Nearest;
		heightShader.setPriority(50);
		bm.addShader(heightShader);

		var block = {
			heightShader: heightShader,
			bitmap: bm,
		};

		blocks.push(block);

		return block;
	}
}
