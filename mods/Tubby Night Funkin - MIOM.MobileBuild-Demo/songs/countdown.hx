var countdownSprite:FunkinSprite;

function onPostCountdown(e) {
    if (!countdownSprite.visible)
        countdownSprite.visible = true;
    countdownSprite.playAnim(Std.string(e.swagCounter), true);
    remove(e.sprite);
    if (e.swagCounter > 3)
        remove(countdownSprite);
}

function postCreate() {
    if(FlxG.save.data.botplay) {
         importScript("data/scripts/botplay");
    }
    if(FlxG.save.data.MiddleScroll) {
         importScript("data/scripts/MiddleScroll");
    }
    if(FlxG.save.data.pe) {
         importScript("data/scripts/hwd");
    }
    countdownSprite = new FunkinSprite().loadSprite(Paths.image("game/countdown"));
    countdownSprite.addAnim("0", "3");
    countdownSprite.addAnim("1", "2");
    countdownSprite.addAnim("2", "1");
    countdownSprite.addAnim("3", "go");
    countdownSprite.visible = false;
    countdownSprite.animation.timeScale = Conductor.startingBPM / 60;
    countdownSprite.antialiasing = true;
    countdownSprite.zoomFactor = 0;
    countdownSprite.scrollFactor.set();
    countdownSprite.screenCenter();
    countdownSprite.x += 25;
    countdownSprite.y += 15;

    add(countdownSprite);
    
}