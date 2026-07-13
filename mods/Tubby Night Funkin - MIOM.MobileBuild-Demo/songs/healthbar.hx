var fakeCamHUD:FlxCamera;

function create() {
    fakeCamHUD = new FlxCamera();
    fakeCamHUD.bgColor = FlxColor.TRANSPARENT;
    
    FlxG.cameras.add(fakeCamHUD, false);
}

function postCreate() {
	healthOverlay = new FlxSprite().loadGraphic(Paths.image("game/Newhealthbar"));
    healthOverlay.cameras = [camHUD];
    healthOverlay.screenCenter(FlxAxes.x);
    healthBar.screenCenter(FlxAxes.x);
    healthOverlay.y = 610;
    healthBar.y = 645;
    if(downscroll) healthBar.y += 15;
    healthBar.numDivisions = 900;
    insert(members.indexOf(iconP1), healthOverlay);
    healthBarBG.visible = false;
    healthOverlay.antialiasing = Options.antialiasing;
    healthBar.scale.set(1,2);

    comboGroup.setPosition(550, 250);
}

function postUpdate(_) {
    comboGroup.cameras = [fakeCamHUD];
    fakeCamHUD.setPosition(camHUD.x, camHUD.y);
    fakeCamHUD.zoom = camHUD.zoom;
    fakeCamHUD.angle = camHUD.angle;
    healthOverlay.alpha = healthBarBG.alpha; //Okay
    healthOverlay.shader = healthBarBG.shader; //Okay
}