import modchart.backend.standalone.Adapter;

function postCreate(){
    FlxG.mouse.visible = false;
    camZooming = true;
    camGame.zoom = defaultCamZoom; 
}

function destroy(){
    FlxG.signals.postDraw.remove(Adapter.instance?.postDraw); //crashes if not
    FlxG.mouse.visible = true;
}
