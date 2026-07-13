
function postCreate() {
	var dipsy = strumLines.members[3].characters[0];
	remove(dipsy);
	insert(members.indexOf(dad)-1, dipsy);
	blackBarThingie = new FunkinSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
    blackBarThingie.zoomFactor = 0;
    blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width + 500));
    blackBarThingie.scrollFactor.set(0, 0);
    blackBarThingie.screenCenter();
    blackBarThingie.alpha = 0;

    remove(camHUD);
    add(blackBarThingie);
    add(camHUD);
}

function stepHit(curStep) {
	if (curSong == 'lighthearted') {
		switch (curStep) {
			case 258 | 768:
				camZoomingInterval = 1;
			case 512 | 1025:
				camZoomingInterval = 4;
			case 554 | 1088:
				camZoomingInterval = 2;
		}
	}

	if (curSong == 'radiant') {
		switch (curStep) {
			case 240 | 384 | 880 | 896:
				camZoomingInterval = 1;
			case 256 | 640 | 1152:
				camZoomingInterval = 4;
			case 260:
				camZoomingInterval = 2;
			case 1288:
            blackBarThingie.cameras = [camHUD];
            blackBarThingie.alpha = 1;
		}

    }
}