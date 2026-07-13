import haxe.ds.ObjectMap;

var frozenCharacters:ObjectMap<Character, Bool> = new ObjectMap();
var frozenStrums:ObjectMap<Strum, Bool> = new ObjectMap();

function onNoteHit(e) {
    if (e.noteType == "BfNote") {
        e.preventAnim();
        strumLines.members[1].characters[0].playSingAnim(e.direction);

        for (char in strumLines.members[1].characters){
            if (e.note.isSustainNote) frozenCharacters.set(char, true);
            if (e.note.animation.name == "holdend") frozenCharacters.remove(char);
        }
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