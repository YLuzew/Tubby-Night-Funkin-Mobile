import hxvlc.flixel.FlxVideoSprite;

public var video: FlxVideoSprite;
var vidList:Map<String, FlxVideoSprite> = [];
var autoPause = true;
function create() {
    camOther = new FlxCamera();
    FlxG.cameras.add(camOther, false);
    camOther.bgColor = FlxColor.TRANSPARANT;

    camBelowHud = new FlxCamera();
    camBelowHud.bgColor = FlxColor.TRANSPARANT;
    FlxG.cameras.remove(camHUD, false);
    FlxG.cameras.add(camBelowHud, false);
    FlxG.cameras.add(camHUD, false);
}
function postCreate(){
    var events = PlayState.SONG.events;

    for (i in events)
    {
        if (i.name == "video event") {
            var vidName = i.params[0];
            var video = new FlxVideoSprite(0, 0);
            video.load(Assets.getPath(Paths.video(vidName)), [':no-audio']);
            video.play();
            video.visible = false;
            add(video);
        }
    }
}
//create the video
function makeVid(x, y, vidName, noAudio){
    var video = new FlxVideoSprite(x, y);
    video.load(Assets.getPath(Paths.video(vidName)), [(noAudio ? ':no-audio' : ':audio')]);
    vidList.set(vidName, video);
    return video;
}

//the event, thanks to furo for the help for audio and fullscreen

function onEvent(eventEvent) {
    if (eventEvent.event.name == "video event") {
        var params = eventEvent.event.params;
        var vidName = params[0];
        var scale = params[1];
        var x = params[2];
        var y = params[3];
        var cam = params[4];
        var middle:Bool = params[5];
        var oppStrum:Bool = params[6];
        var playerStrum:Bool = params[7];
        var index = params[8];
        var audio = params[9];
        var fullscreen = params[10];

        
        video = vidList.get(vidName);
        if (video == null) {
            video = makeVid((cam == "camGame")?x:0, (cam == "camGame")?y:0, vidName, !audio);
        }

        video.scale.set(scale, scale);
        video.antialiasing = Options.antialiasing;
        video.visible = true;
        video.play();
        

        video.bitmap.onFormatSetup.add(function():Void
        {
            if (video.bitmap != null && video.bitmap.bitmapData != null)
            {
                if (fullscreen || cam == "camHUD/showHUD" || cam == "camOther (Below Hud)" || cam == "camOther")
                {
                    var scale:Float = Math.min(FlxG.width / video.bitmap.bitmapData.width, FlxG.height / video.bitmap.bitmapData.height);
                    video.setGraphicSize(video.bitmap.bitmapData.width * scale, video.bitmap.bitmapData.height * scale);
                    video.updateHitbox();
                }
                video.updateHitbox();
                if (middle)
                {
                    video.screenCenter();
                }
            }
        }); 

        switch (cam) {
            case "camGame":
                if (index == "" || stage.stageSprites[index] == null)
                    if (gf != null)
                        insert(members.indexOf(gf), video);
                    else
                    insert(members.indexOf(dad), video);
                else
                    insert(members.indexOf(stage.stageSprites[index]), video);

            case "camHUD/showHUD":
                insert(0, video);
                video.camera = camHUD;
                updateOppStrumVisibility(oppStrum ? 0 : 1);
                updatePlayerStrumVisibility(playerStrum ? 0 : 1);
            case "camOther":
                updateHUDVisibility(0);
                insert(0, video);
                video.camera = camOther;
                updateOppStrumVisibility(0);
                updatePlayerStrumVisibility(0);
            case "camOther (Below Hud)":
                insert(0, video);
                video.camera = camBelowHud;
                updateOppStrumVisibility(oppStrum ? 0 : 1);
                updatePlayerStrumVisibility(playerStrum ? 0 : 1);
        }



        video.bitmap.onEndReached.add(() -> {
            video.destroy();
            updateHUDVisibility(1);
            updateOppStrumVisibility(1);
            updatePlayerStrumVisibility(1);
        });
    }
}

//alpha shit

function updateHUDVisibility(alpha:Float) {
    for (hud in [iconP1, iconP2, healthBarBG, healthBar]){
        hud.alpha = alpha;
    }
}

function updateOppStrumVisibility(alpha:Float) {
    for (daStrum in cpuStrums.members) {
            FlxTween.tween(daStrum, {alpha: alpha}, 0.2);
    }
    for (daNote in cpuStrums.notes.members) {
            FlxTween.tween(daNote, {alpha: alpha}, 0.2);
    }
}

function updatePlayerStrumVisibility(alpha:Float) {
    for(daStrum in playerStrums.members) {
        FlxTween.tween(daStrum, {alpha: alpha}, 0.2);
    }
    for (daNote in playerStrums.notes.members) {
        FlxTween.tween(daNote, {alpha: alpha}, 0.2);
    }
}

//video pause

function onFocus() {
    if (video != null) {
        if (PlayState.instance.paused) {
            video.pause();
        } else {
            video.resume();
        }
    }
}

function onGamePause() {
    PlayState.instance.paused = true;
    persistentUpdate = false;
    persistentDraw = true;
    if (video != null) {
        video.pause();
    }
}

function update(elapsed) {
    if (!PlayState.instance.paused && video != null) {
        video.resume();
        autoPause = true;
    }
}