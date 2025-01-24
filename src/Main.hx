import h2d.Bitmap;
import h2d.RenderContext;
import h2d.Tile;
import h2d.filter.Filter;
import h3d.pass.ScreenFx;
import hxd.Key;
import hxd.Window;
import hxsl.Types.Texture;

class HeightFilter extends Filter {
	var shader:HeightScreenShader;
	var pass:ScreenFx<HeightScreenShader>;

	public function new(z:Int) {
		super();
		useScreenResolution = true;

		var shader = new HeightScreenShader();
		shader.baseHeight = z;
		shader.heightTexture = hxd.Res.block_height.toTexture();
		shader.heightTexture.filter = Nearest;

		pass = new ScreenFx(shader);
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

class Main extends hxd.App {
	var heightFilters:Array<HeightFilter> = [];
	var blockShaders:Array<BlockShader> = [];
	var sceneHeightTexture:Texture;
	var overlay:Bitmap;

	static function main() {
		new Main();
		hxd.Res.initLocal();
	}

	override function init() {
		var window = Window.getInstance();

		// create a new texture to render height data into
		sceneHeightTexture = new Texture(window.width, window.height, [Target]);
		sceneHeightTexture.filter = Nearest;
		sceneHeightTexture.clear(0x440000);

		overlay = new Bitmap(Tile.fromTexture(sceneHeightTexture), s2d);

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
	}

	override function update(dt:Float) {
		// enable all height filters
		for (f in heightFilters) {
			f.enable = true;
		}

		// disable block shaders
		for (f in blockShaders) {
			f.enabled = 0;
		}

		overlay.visible = false;

		// render to texture (size of screen)
		s2d.drawTo(sceneHeightTexture);

		// disable filters
		for (f in heightFilters) {
			f.enable = false;
		}

		// re-enabled all block shaders?
		for (f in blockShaders) {
			f.enabled = 1;
		}

		// toggle showing height texture with SPACE key
		overlay.visible = hxd.Key.isDown(Key.SPACE);
	}

	function makeblock(x:Int, y:Int, z:Int):Bitmap {
		var bm = new Bitmap(hxd.Res.block.toTile(), s2d);
		bm.width = 100;
		bm.height = 100;
		bm.x = x;
		bm.y = y;

		// want to use scene height texture as input to the block shader
		var shader = new BlockShader();
		shader.sceneHeightTexture = sceneHeightTexture;
		bm.addShader(shader);
		blockShaders.push(shader);

		// add the HeightFilter
		var filter = new HeightFilter(z);
		filter.enable = false;
		bm.filter = filter;
		heightFilters.push(filter);

		return bm;
	}
}
