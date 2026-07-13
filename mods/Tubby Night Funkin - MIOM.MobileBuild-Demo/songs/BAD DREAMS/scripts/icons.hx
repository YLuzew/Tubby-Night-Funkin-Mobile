playCutscenes = true;
public var icoP1:HealthIcon;

function postCreate() {
    icoP1 = new HealthIcon("gf", true);
    icoP1.y = healthBar.y - (icoP1.height / 2);
    icoP1.cameras = [camHUD];
    insert(members.indexOf(iconP1)+1, icoP1);
    icoP1.origin.set(icoP1.width/2, icoP1.height/2);
}

function update(elapsed:Float){
	icoP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 1, 0))) - (icoP1.width - 200);
    icoP1.y = healthBar.y - (icoP1.height / 2) + 20;
    icoP1.health = 1 - (healthBar.percent / 100);
    iconP1.y =  healthBar.y - (icoP1.height / 2) - 30;
    icoP1.scale = iconP1.scale;
}