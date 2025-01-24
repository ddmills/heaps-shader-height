import HeightScreenShader.HeightShader;
import h2d.Bitmap;
import h2d.RenderContext;
import h2d.Tile;
import h2d.filter.Filter;
import h2d.filter.Shader;
import h3d.pass.ScreenFx;
import hxd.Key;
import hxd.Window;
import hxsl.Types.Texture;

class ScreenHeightFilter extends Filter {
	var shader:HeightScreenShader;
	var pass:ScreenFx<HeightScreenShader>;
	var targetTexture:Texture;

	public function new(targetTexture:Texture) {
		super();
		useScreenResolution = true;
		this.targetTexture = targetTexture;
		targetTexture.filter = Nearest;

		// pass = new ScreenFx(shader);
	}

	override function draw(ctx:RenderContext, input:Tile):Tile {
		input.getTexture().filter = Nearest;

		var out = ctx.textures.allocTileTarget("height", input);
		ctx.engine.pushTarget(out);
		pass.render();
		ctx.engine.popTarget();

		return h2d.Tile.fromTexture(out);
	}
}

typedef Block = {
	heightShader:HeightShader,
	bitmap:Bitmap,
}

class Main extends hxd.App {
	var screenHeightFilter:ScreenHeightFilter;
	var sceneHeightTexture:Texture;
	var overlay:Bitmap;
	var blocks:Array<Block> = [];

	static function main() {
		new Main();
		hxd.Res.initLocal();
	}

	override function init() {
		engine.backgroundColor = 0x206980;

		var window = Window.getInstance();

		// create a new texture to render height data into
		sceneHeightTexture = new Texture(window.width, window.height, [Target]);
		sceneHeightTexture.filter = Nearest;
		sceneHeightTexture.clear(0x000000);
		screenHeightFilter = new ScreenHeightFilter(sceneHeightTexture);
		var s = new FullScreenShader();

		window.addResizeEvent(() -> {
			sceneHeightTexture.resize(window.width, window.height);
			s.pad = (1 / window.height) * 2;
		});

		s.pad = (1 / window.height) * 2;
		s.heightTexture = sceneHeightTexture;
		s2d.filter = new Shader<FullScreenShader>(s);

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

		overlay = new Bitmap(Tile.fromTexture(sceneHeightTexture), s2d);
	}

	override function update(dt:Float) {
		sceneHeightTexture.clear(0);
		// hide overlay so it doesn't render itself
		overlay.visible = false;

		// add height shaders
		for (b in blocks) {
			// f.enabled = 0;
			b.bitmap.addShader(b.heightShader);
		}

		s2d.filter.enable = false;
		// render to texture (size of screen)
		s2d.drawTo(sceneHeightTexture);

		// remove height shaders
		for (b in blocks) {
			b.bitmap.removeShader(b.heightShader);
		}

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

		// add the HeightFilter
		// var filter = new HeightFilter(z);
		// filter.enable = false;
		// bm.filter = filter;
		// heightFilters.push(filter);

		// Note this shader outputs the right info, but is not a ScreenShader so cannot be used in a filter
		var heightShader = new HeightShader();
		heightShader.baseHeight = z;
		heightShader.heightTexture = hxd.Res.block_height.toTexture();
		heightShader.heightTexture.filter = Nearest;

		var block = {
			heightShader: heightShader,
			bitmap: bm,
		};

		blocks.push(block);

		return block;
	}
}
