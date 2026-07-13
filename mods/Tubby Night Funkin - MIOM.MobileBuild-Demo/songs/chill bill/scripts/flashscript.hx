function postCreate() {
    strumLines.members[2].characters[0].alpha = 0;
}
var cutscenePlayed:Bool = false;

function update(delta) {
    if (!inCutscene && !cutscenePlayed) {
        cutscenePlayed = true;
        dad.playAnim("intro");
    }
}

function stepHit(curStep) {
        switch(curStep) {
            case 32 | 160 | 288 | 2081:
                flash(FlxColor.WHITE, 0,1,100); //color, blend, time, alpha
			case 288 | 704:
				camZoomingInterval = 1;
			case 1088 | 2000:
				camZoomingInterval = 4;
			case 554 | 1088:
				camZoomingInterval = 2;
			case 553:
				strumLines.members[2].characters[0].alpha = 1;
				strumLines.members[2].characters[0].playAnim('voice-trumpet-pops-out');
			case 819: strumLines.members[2].characters[0].alpha = 0;
		}
	}
function flash(color:FlxColor,blend, time,alpha) {

    flashs = new FlxSprite().makeSolid(FlxG.width * 2, 9999, color);
    flashs.scrollFactor.set(0, 0);
    flashs.screenCenter();
    flashs.alpha = alpha;
    insert(members.indexOf(gf)+10, flashs);
    flashs.blend = blend;

    FlxTween.tween(flashs, {alpha:0}, time, {ease: FlxEase.smootherStepInOut});

    new FlxTimer().start(time, function(tmr:FlxTimer){
        remove(flashs);
        });
    }
public function scrollSpeed_tween(value:Float, duration:Float)
FlxTween.tween(PlayState.instance, {scrollSpeed: value}, duration); 
