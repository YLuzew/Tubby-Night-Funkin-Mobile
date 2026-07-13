import openfl.display.BlendMode;
import openfl.display3D.Context3DWrapMode;
import openfl.geom.Matrix3D;
import openfl.geom.Vector3D;
import funkin.backend.shaders.CustomShader;
import funkin.backend.shaders.FunkinShader;

var phases:Map<Int, Script> = [];
var currentPhase:Script;

var warpShader:CustomShader;
var anjayShader:CustomShader;
var bloomShader:FunkinShader;
var distortionWarpValue:Array<Float> = [1];
var anjayRadiusValue:Array<Float> = [0];
var anjayStrength:Float = 0;
var anjayStrengthValue:Array<Float> = [0];
var floorSprite:FunkinSprite;
var floorProjectionArray:Array<Float> = [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1];
var floorViewArray:Array<Float> = [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1];
var floorModelArray:Array<Float> = [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1];
var floorBeatArray:Array<Float> = [0];
var floorStrengthArray:Array<Float> = [0];
var camShake:Float = 0;
var lastCamShake:Float = 0;
var _matrix3D:Matrix3D = new Matrix3D(); 
var floorVert = '#pragma header
uniform mat4 projectionMatrix;
uniform mat4 viewMatrix;
uniform mat4 modelMatrix;
varying vec4 worldPosition;
varying vec4 viewPosition;
vec4 project(vec4 vertex) {
    mat4 internalMatrix = openfl_Matrix;
    vec4 internalOffset = vec4(internalMatrix[3].xy / vec2(internalMatrix[0][0], internalMatrix[1][1]), 0.0, 0.0);
    internalMatrix[3].xy = vec2(0.0);
    return projectionMatrix * internalMatrix * (viewPosition = viewMatrix * (worldPosition = (modelMatrix * vertex) + internalOffset));
}
void main() {
    openfl_Alphav = openfl_Alpha * alpha;
    openfl_TextureCoordv = openfl_TextureCoord;
    if (openfl_HasColorTransform) {
        openfl_ColorMultiplierv = openfl_ColorMultiplier;
        openfl_ColorOffsetv = openfl_ColorOffset / 255.0;
    }
    if (hasColorTransform) {
        openfl_ColorOffsetv = colorOffset / 255.0;
        openfl_ColorMultiplierv = colorMultiplier;
    }
    gl_Position = project(openfl_Position);
}';
var floorFrag = '#pragma header
varying vec4 worldPosition;
varying vec4 viewPosition;
uniform float beat;
uniform float strength;
void main() {
    float fog = max(min((viewPosition.z / viewPosition.w) * 0.0005 + 1.3, 1.0), 0.0);
    float fogAlpha = max(min((viewPosition.z / viewPosition.w) * 0.00045 + 1.475, 1.0), 0.0);
    if (fogAlpha == 0.0) discard;
    vec2 uv = openfl_TextureCoordv * 12.0;
    uv.x += cos(uv.y * 2.0 + beat) * strength * 0.1;
    uv.y += cos(uv.x * 2.0 + beat) * strength * 0.1;
    vec4 color = flixel_texture2D(bitmap, uv);
    gl_FragColor = vec4(color.rgb * fog, color.a * fogAlpha);
}';

function coolLerp(a, b, ratio, dt)
    return FlxMath.lerp(b, a, Math.pow(1 - ratio, dt * 60));

function outputMatrixArray(matrix:Matrix3D, arr:Array<Float>) {
    for (i in 0...16)
        arr[i] = matrix.rawData.get(i);
    return arr;
}

function calculateProjectionMatrix(arr:Any, fov:Float, near:Float, far:Float) {
    var focalLength = 1.0 / Math.tan((fov * (Math.PI / 180)) * 0.5);
    var z = 1.0 / (far - near);
    arr[10] = -2.0 * z;
    arr[14] = -(near + far) * z;
    arr[11] = 1.0 / focalLength;
    return arr;
}

function calculateObjectMatrix(arr:Any, x:Float, y:Float, z:Float, rx:Float, ry:Float, rz:Float) {
    _matrix3D.identity();
    _matrix3D.appendRotation(rx, Vector3D.X_AXIS);
    _matrix3D.appendRotation(ry, Vector3D.Y_AXIS);
    _matrix3D.appendRotation(rz, Vector3D.Z_AXIS);
    outputMatrixArray(_matrix3D, arr);
    arr[12] = x;
    arr[13] = y;
    arr[14] = z;
    return arr;
}

function draw3DObject(obj:FlxSprite) {
    if (obj.alpha == 0)
        return;

    for (camera in obj.cameras) {
        if (!camera.visible || !camera.exists)
            continue;

        var angle = camera.angle;
        camera.angle = 0;
        obj.drawComplex(camera);
        camera.angle = angle;
    }
}


function create() {

    for (phaseI in 2...6) {
        phases.set(phaseI, scripts.getByPath("songs/BAD DREAMS/scripts/Phase"+Std.string(phaseI)+".hx"));
    }

    camGame.bgColor = 0x0000000;
    
    if (!Options.lowMemoryMode) {
        bloomShader = new FunkinShader(Assets.getText(Paths.fragShader("bloom")));
        FlxG.camera.addShader(bloomShader);

        anjayShader = new CustomShader(Options.lowMemoryMode ? "anjaylq" : "anjay");
        anjayShader.data.radius.value = anjayRadiusValue;
        anjayShader.data.strength.value = anjayStrengthValue;
        anjayShader.data.offset.value = [0, 0];

        warpShader = new CustomShader("warp");
        warpShader.data.distortion.value = distortionWarpValue;
        camGame.addShader(warpShader);
        floorSprite = new FunkinSprite().loadGraphic(Paths.image('stages/badDreams/patern'));
        floorSprite.scrollFactor.set();
        floorSprite.shader = new FunkinShader(floorFrag, floorVert);
        floorSprite.shader.data.projectionMatrix.value = floorProjectionArray;
        floorSprite.shader.data.viewMatrix.value = floorViewArray;
        floorSprite.shader.data.modelMatrix.value = floorModelArray;
        floorSprite.shader.data.beat.value = floorBeatArray;
        floorSprite.shader.data.strength.value = floorStrengthArray;
        floorSprite.shader.data.bitmap.wrap = Context3DWrapMode.REPEAT;
        floorSprite.antialiasing = true;
        floorSprite.onDraw = draw3DObject;
        floorSprite.scale.set(1 * 19, 2 * 19);
        floorSprite.offset.set(floorSprite.frameWidth * 0.5, floorSprite.frameHeight * 0.5);
        insert(members.indexOf(boyfriend), floorSprite);
        stage.stageSprites.set("floor", floorSprite);
        
        calculateProjectionMatrix(floorProjectionArray, 80, -512, 1024);
        calculateObjectMatrix(floorModelArray, 640, 100, 0, 90, 0, 0);
    } else {
        floorSprite = new FunkinSprite().loadGraphic(Paths.image('stages/badDreams/pattern'));
        floorSprite.scrollFactor.set(1, 1);
        floorSprite.scale.set(4, 2.5);
        floorSprite.x = 100;
        floorSprite.y = 200;
        insert(members.indexOf(boyfriend), floorSprite);
        stage.stageSprites.set("floor", floorSprite);
    }

    blackBarThingie = new FlxSprite().makeSolid(FlxG.width + 500, FlxG.height, FlxColor.BLACK);
    blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width + 9000));
    blackBarThingie.scrollFactor.set(0, 0);
    blackBarThingie.screenCenter();
    blackBarThingie.alpha = 0;
    add(blackBarThingie);
}

function switchPhase(phaseIndex:Int) {
    if (currentPhase != null)
        currentPhase.call("closePhase");    
    currentPhase = phases[phaseIndex];

    currentPhase.call("startPhase");
}

function draw() {
    if (!Options.lowMemoryMode) {
        calculateObjectMatrix(floorViewArray, -camGame.scroll.x - 439, -camGame.scroll.y + 589.5, 0, 0, 0, camGame.angle);
    }
}

function update(elapsed:Float) {
    camGame.scroll.y -= lastCamShake;
    lastCamShake = 0;
}

function stepHit(curStep:Int) {
    switch (curStep) {
        case 1424:
            camHUD.alpha = 0;
        case 1672:
            FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.linear});              
        case 1680:
            if (!Options.lowMemoryMode) {
                calculateObjectMatrix(floorModelArray, 640, 100, 0, 90, 45, 0);
            } else {
                floorSprite.loadGraphic(Paths.image('stages/badDreams/bg'));
				 floorSprite.y = -600;
            }
        case 2512:
            switchPhase(2);
        case 3460:
            FlxTween.tween(light, {alpha: 0}, 3, {ease: FlxEase.sinOut});
            FlxTween.tween(blackBarThingie, {alpha: 1}, 2, {ease: FlxEase.sinOut});
        case 3489:
            switchPhase(3);
        case 3496:
            FlxTween.tween(blackBarThingie, {alpha: 0}, 1.5, {ease: FlxEase.sinOut});
        case 3524:
            FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.linear}); 
        case 4304:
            switchPhase(4);
        case 4560:
            switchPhase(5);
    }
}

function postUpdate()
    if (currentPhase == null)
        defaultCamZoom = (curCameraTarget == 0) ? 0.4 : 0.5;