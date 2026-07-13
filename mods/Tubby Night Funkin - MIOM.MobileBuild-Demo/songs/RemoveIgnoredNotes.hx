// RemoveIgnoredNotes.hx
// 功能：在音符生成时，将 ignoredNoteTypes 列表中的音符彻底移除（不可见、无判定）

var ignoredNoteTypes:Array<String> = ["Hurt Note"];

function onNoteCreation(event:NoteCreationEvent) {
    

    if (!FlxG.save.data.mechanics && ignoredNoteTypes.indexOf(event.note.noteType) != -1 && FlxG.save.data.RemoveHurtNote) {
        event.note.strumTime -= 999999;
        event.note.exists = event.note.active = event.note.visible = false;
        return;
    }
}