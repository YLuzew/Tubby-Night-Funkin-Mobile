//
import funkin.game.cutscenes.VideoCutscene;

var name:String = null;
function onOpenSubState(e) if (e.substate is VideoCutscene) {
    e.cancelled = true;
    subState = null;
    script = importScript("data/scripts/skippableVideoTNF");
    TNFCall = e.substate.__callback;
    name = e.substate.path;
    script.call("startVideo", [name, finishTNF]);
}

function finishTNF() {
    script.destroy();
    if (TNFCall != null) TNFCall();
}