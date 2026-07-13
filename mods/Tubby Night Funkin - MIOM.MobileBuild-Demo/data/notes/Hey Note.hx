function onNoteHit(event) {
    if (event.noteType == "Hey Note") {
        event.preventAnim();
        event.character.playAnim("BF HEY!!", true);
    }
}