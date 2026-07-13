import StringTools;
var party = false;
var lightsTween:FlxTween;

var fade:FunkinSprite;

var boyfriendDark:Character;
var dadDark:Character;
var gfDark:Character;
var dipsyDark:Character;
var dipsy:Character;

var excludes = ["noo-noo-bopper", "tinky winky bopper", "laa laa bopper"];

function postCreate() {
    for (strumLine in strumLines.members) {
        for (char in strumLine.characters) {
            if (!Options.lowMemoryMode && Options.gameplayShaders) {
                var shadow = getDropShadow(char);
                if (shadow != null) {
                    shadow.setAdjustColor(-25, -24, 0, -20);
                    shadow.color = 0xFF5DCCFF;
                    shadow.angle = (char.curCharacter == "Boyfriend") ? 135 : 45;
                    shadow.distance = 15;
                    shadow.strength = 1;
                }
            }
        }
    }

    dipsy = strumLines.members[3].characters[0];
    remove(dipsy, false);
    insert(members.indexOf(dad)-1, dipsy);

    dad.alpha = 0;
    dadDark = new Character(dad.x, dad.y, "po dark", false);
    strumLines.members[0].characters.push(dadDark);
    insert(members.indexOf(dad) + 1, dadDark);

    bf.alpha = 0;
    boyfriendDark = new Character(bf.x, bf.y, "Boyfriend dark", true);
    strumLines.members[1].characters.push(boyfriendDark);
    insert(members.indexOf(bf) + 1, boyfriendDark);

    gf.alpha = 0;
    gfDark = new Character(gf.x, gf.y, "gf po week dark", false);
    strumLines.members[2].characters.push(gfDark);
    insert(members.indexOf(gf) + 1, gfDark);

    dipsy.alpha = 0;
    dipsyDark = new Character(dipsy.x, dipsy.y, "dipsy-po-week-dark", false);
    strumLines.members[3].characters.push(dipsyDark);
    insert(members.indexOf(dipsy) + 1, dipsyDark);

    partyMode(false);

    fade = new FunkinSprite().makeSolid(camGame.width, camGame.height, FlxColor.BLACK);
    fade.scrollFactor.set();
    fade.zoomFactor = 0;
    add(fade);
}

function onSongStart()
    FlxTween.tween(fade, {alpha:0}, 2);

function beatHit(curStep) {
    if (party) {
        if (lightsTween != null)
            lightsTween.cancel();
            
        if (!Options.lowMemoryMode && stage.stageSprites.exists("lights-back")) {
            stage.stageSprites["lights-back"].alpha = 1;
            lightsTween = FlxTween.tween(stage.stageSprites["lights-back"], {alpha: 0}, 1);
        }
    }
}

function stepHit(curStep) {
    switch (curStep) {
        case 144:
            partyMode(true);
        case 1248:
            partyMode(false); 
            fade = new FunkinSprite().makeSolid(camGame.width, camGame.height, FlxColor.BLACK);
            fade.scrollFactor.set();
            fade.zoomFactor = 0;
            add(fade);
        case 1276:
            FlxTween.tween(fade, {alpha:0}, 2);
        case 1408:
            partyMode(true);
        case 1696:
            FlxTween.tween(fade, {alpha:1}, 3);
    }
}

function partyMode(value:Bool) {
    party = value;

    if (value) {
        for (spr in stage.stageSprites) {
            spr.color = FlxColor.WHITE;
        }

        for (spr in excludes) {
            stage.stageSprites[spr + " dark"].alpha = 0;
            stage.stageSprites[spr].alpha = 1;
        }

        if (!Options.lowMemoryMode && Options.gameplayShaders && stage.stageSprites.exists("tub-boppers")) {
            var shadow = getDropShadow(stage.stageSprites["tub-boppers"]);
            if (shadow != null) shadow.baseHue = -24;
        }

        if (!Options.lowMemoryMode) {
            if (stage.stageSprites.exists("overlay")) stage.stageSprites["overlay"].visible = true;
            if (stage.stageSprites.exists("mainLight")) stage.stageSprites["mainLight"].visible = true;
        }

        dadDark.alpha=0;
        boyfriendDark.alpha=0;
        gfDark.alpha=0;
        dipsyDark.alpha=0;
        
        dad.alpha = 1;
        boyfriend.alpha = 1;
        gf.alpha = 1;
        dipsy.alpha = 1;

    } else {
        if (lightsTween != null)
            lightsTween.cancel();

        for (sprName in stage.stageSprites.keys()) {
            var spr = stage.stageSprites[sprName];
            if (excludes.contains(sprName)) {
                spr.alpha = 0;
                var sprite = stage.stageSprites[sprName + " dark"];
                sprite.alpha = 1;
            } else if (!StringTools.endsWith(sprName, " dark"))
                spr.color = 0x0C0D1D;
        }

        if (stage.stageSprites.exists("tub-boppers")) {
            stage.stageSprites["tub-boppers"].shader = null;
        }

        if (!Options.lowMemoryMode) {
            if (stage.stageSprites.exists("overlay")) stage.stageSprites["overlay"].visible = false;
            if (stage.stageSprites.exists("mainLight")) stage.stageSprites["mainLight"].visible = false;
        }

        dadDark.alpha=1;
        boyfriendDark.alpha=1;
        gfDark.alpha=1;
        dipsyDark.alpha=1;
        
        dad.alpha = 0;
        boyfriend.alpha = 0;
        gf.alpha = 0;
        dipsy.alpha = 0;
    }
}