var onPhase = false;
var gfSinging = true;
var switchingTransition = false;

function startPhase() {
    onPhase = true;
    stage.stageSprites["divider"].alpha = 1;

    bf.animation.onFinish.add((animationName) -> {
        if (animationName == "character-swap") {
            switchingTransition = false;
            strumLines.members[2].characters[0].alpha = 1;
        }
    });

    bf.idleSuffix = "-alt";

}

function closePhase() {
    onPhase = false;
    stage.stageSprites["divider"].alpha = 0;
}

function onPlayerHit(e)
    if (switchingTransition && onPhase) e.preventAnim();

function onPlayerMiss(e)
    if (switchingTransition && onPhase) e.preventAnim();

function update()
    if (onPhase)
        defaultCamZoom = 0.6;

function onEvent(e) {
	if (e.event.name == "bad dreams character swap") {
        strumLines.members[2].characters[0].alpha = 0;
		gfSinging = e.event.params[0];
		bf.playAnim("character-swap", true, "NONE", !gfSinging);
        switchingTransition = true;


		if (gfSinging) {
            bf.idleSuffix = "-alt";
            strumLines.members[2].characters[0].idleSuffix = "";
			remove(strumLines.members[2].characters[0]);
			insert(members.indexOf(boyfriend) + 10, strumLines.members[2].characters[0]);
		} else {
            bf.idleSuffix = "";
            strumLines.members[2].characters[0].idleSuffix = "-alt";
			remove(strumLines.members[2].characters[0]);
			insert(members.indexOf(boyfriend) - 1, strumLines.members[2].characters[0]);
		}
	}
}