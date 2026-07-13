import haxe.ds.ObjectMap;

var strumLineIndex = 0;

var frozenCharacters:ObjectMap<Character, Bool> = new ObjectMap();
var frozenStrums:ObjectMap<Strum, Bool> = new ObjectMap();

function onNoteHit(e) {
    if (e.noteType == "ExtraOppNote") {
        e.preventAnim();
        strumLines.members[strumLineIndex].characters[0].playSingAnim(e.direction);

        for (char in strumLines.members[strumLineIndex].characters){
            if (e.note.isSustainNote) frozenCharacters.set(char, true);
            if (e.note.animation.name == "holdend") frozenCharacters.remove(char);
        }
    }
}

function onPlayerMiss(e) {
    if (e.noteType == "ExtraOppNote") {
        e.preventAnim();
        strumLines.members[strumLineIndex].characters[0].playSingAnim(e.direction, "miss", "MISS");

        for (a in strumLines.members[strumLineIndex].characters) frozenCharacters.set(a, false);
        frozenStrums.set(strumLines.members[strumLineIndex].members[e.note.strumID], false);
    }
}

function onEvent(e) {
    if (e.event.name == "Change Extra Opponent note") {
        strumLineIndex = e.event.params[0];
    }
}

function postUpdate(elapsed:Float) {
    for (char in frozenCharacters.keys()) {
        var bool = frozenCharacters.get(char);
        if (char.animateAtlas == null) char.animation.paused = bool;
        else {
            var isPaused = char.animateAtlas.anim.paused;
            if (bool && !isPaused) char.animateAtlas.anim.pause();
            else if (!bool && isPaused) char.animateAtlas.anim.play();
        }
    }
}
