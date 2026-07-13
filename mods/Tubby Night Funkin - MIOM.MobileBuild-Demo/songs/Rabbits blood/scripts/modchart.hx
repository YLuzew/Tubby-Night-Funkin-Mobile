import modchart.Manager;
import flixel.math.FlxMath;

var manager:Manager;
var queuedFuncs = [];
var hasActivated:Bool = false; 

function activateModchart() {
    manager = new Manager(PlayState.instance);
    add(manager);

    manager.addModifier('transform');
    manager.addModifier('opponentSwap');
    manager.addModifier('drunk');
    manager.addModifier('tipsy');
    manager.addModifier('schmovinTipsy');
    manager.addModifier('confusion');
    manager.addModifier('rotate');
    manager.addModifier('centerRotate');
    manager.addModifier('spiral');
    manager.addModifier('invert');
    manager.addModifier('wiggle');
    manager.addModifier('receptorScroll');
    manager.addModifier('beat');

    manager.setPercent('opponentSwap', 0);

    queueFunc(448, 576, function(beat:Float) {
        var startBeat = 112.0; 
        var progress = (beat - startBeat) / 2.0;

        if (progress > 1) progress = 1;
        if (progress < 0) progress = 0;
        
        var easeMultiplier = FlxEase.quadInOut(progress);
        
        var radius = 100 * easeMultiplier; 
        for (col in 0...4) {
            var visualOffset = col * 0.5;
            var xVal = Math.sin(beat + visualOffset) * radius;
            
            manager.setPercent('x' + col, xVal, 1); 
            manager.setPercent('z' + col, Math.cos(beat + visualOffset) * (50 * easeMultiplier), 1); 
        }
    });

    for (i in 0...4) {
        e_s(576, 4, FlxEase.quadOut, 0, 'x' + i, 1);
        e_s(576, 4, FlxEase.quadOut, 0, 'z' + i, 1);
    }

    e_s(640, 8, FlxEase.quadInOut, 1.0, 'wiggle');
    e_s(640, 8, FlxEase.quadInOut, 0.5, 'tipsy');

    e_s(911, 8, FlxEase.quadOut, 0, 'wiggle');
    e_s(911, 8, FlxEase.quadOut, 0, 'tipsy');

    e_s(1168, 8, FlxEase.quadOut, 0.6, 'beat'); 
    e_s(1424, 8, FlxEase.quadInOut, 0, 'beat');
}

function update(elapsed) {
    var curBeatFloat = Conductor.songPosition / Conductor.crochet;
    var curStepFloat = curBeatFloat * 4.0; 


    if (!hasActivated && curStepFloat >= 379) {
        activateModchart();
        hasActivated = true;
    }


    for (obj in queuedFuncs) {
        if (curBeatFloat >= obj.startBeat && curBeatFloat < obj.endBeat) {
            obj.callback(curBeatFloat);
        } else if (curBeatFloat > obj.endBeat) {
            queuedFuncs.remove(obj);
        }
    }
}

function queueFunc(startStep:Float, endStep:Float, callback:Float->Void) {
    queuedFuncs.push({
        startBeat: startStep / 4,
        endBeat: endStep / 4,
        callback: callback
    });
}

function e_s(step:Float, stepsLen:Float, ease:EaseFunction, val:Float, mod:String, pn:Int = -1) {
    manager.ease(mod, step / 4, stepsLen / 4, val, ease, pn);
}

function s_s(step:Float, val:Float, mod:String, pn:Int = -1) {
    manager.set(mod, step / 4, val, pn);
}

function f_s(step:Float, func:Void->Void) {
    manager.callback(step / 4, (_) -> {
        func();
    });
}