public var icoP1:HealthIcon;
public var icoP2:HealthIcon;

function postCreate() {

    icoP2 = new HealthIcon("dipsy", false);
    for(ico in [icoP2]) {
        ico.y = healthBar.y - (ico.height / 2);
        ico.cameras = [camHUD];
        insert(members.indexOf(healthBar) + 3, ico);
    }
    iconArray.push(icoP2);

    iconP2.extraOffsets.y = -(icoP2.height / 2) + (downscroll ? 30 : 55);
}

function update(elapsed:Float){
	icoP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 1, 0))) - (icoP2.width + 6);
    icoP2.y = healthBar.y - (icoP2.height / 2) - 20;
    icoP2.health = 1 - (healthBar.percent / 100);
}