
var rainShader:CustomShader;
function create() {
    if(!Options.gameplayShaders)
	{
		disableScript();
		return;
	}


    rainShader = new CustomShader("rainShader");
    camGame.addShader(rainShader);

    rainShader.uScale = FlxG.height / 200;
    rainShader.uIntensity = 0.03;
    rainShader.uTime = 0;
}

function update(elapsed:Float) {
    rainShader.uTime += elapsed;

    rainShader.uCameraBounds = [camGame.viewLeft, camGame.viewTop, camGame.viewRight, camGame.viewBottom];
}

function onGameOver(_)
{
	if (rainShader != null) camGame.removeShader(rainShader);
}