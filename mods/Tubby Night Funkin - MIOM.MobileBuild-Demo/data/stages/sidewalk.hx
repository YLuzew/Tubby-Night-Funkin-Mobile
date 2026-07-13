import flixel.addons.display.FlxBackdrop;

function postCreate() {
	var clouds = new FlxBackdrop(Paths.image("stages/gift-walking satge/clouds"), 1, -10);
	clouds.antialiasing = Options.antialiasing;
	clouds.velocity.set(10);
	insert(members.indexOf(gf), clouds);
	clouds.scrollFactor.set(0.8, 0.8);
	clouds.y = -350;
	clouds.x = 1800;

	var buidlings = new FlxBackdrop(Paths.image("stages/gift-walking satge/buidlings"), 1, -10);
	buidlings.antialiasing = Options.antialiasing;
	buidlings.velocity.set(200);
	insert(members.indexOf(gf), buidlings);
	buidlings.scrollFactor.set(0.8, 0.8);
	buidlings.y = -200;
	buidlings.x = 1800;

	var bushes = new FlxBackdrop(Paths.image("stages/gift-walking satge/bushes"), 1, -10);
	bushes.antialiasing = Options.antialiasing;
	bushes.velocity.set(390);
	insert(members.indexOf(gf), bushes);
	bushes.scrollFactor.set(0.92, 0.92);
	bushes.y = 280;
	bushes.x = 1800;

	var fences = new FlxBackdrop(Paths.image("stages/gift-walking satge/fences"), 1, 1);
	fences.antialiasing = Options.antialiasing;
	fences.velocity.set(400);
	insert(members.indexOf(gf), fences);
	fences.scrollFactor.set(0.95, 0.95);
	fences.y = 100;
	fences.x = 1800;
}


function beatHit() {
	if (curBeat % 1 == 0) {
		for (H in [dad, gf, boyfriend]) {
			H.y = H.y + 30;
			FlxTween.tween(H, {y: H.y - 30}, 0.2);
		}
	}
}

function update() {
	if (gf.y > 200) {
		for (H in [dad, gf, boyfriend]) {
			boyfriend.y = 30;
			dad.y = -400;
			gf.y = -100;
		}
	}
}
