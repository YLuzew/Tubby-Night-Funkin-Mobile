import flixel.group.FlxTypedSpriteGroup;
import flixel.text.FlxTextBorderStyle;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

var group:FlxTypedSpriteGroup;
var background:FlxSprite;
var songNameText:FlxText;
var difficultyText:FlxText;
var composerText:FlxText;
var camCard:FlxCamera;
var calledByEvent = false;

function create() {
    var shuffix = PlayState.variation == null ? "" : ("-"+PlayState.variation);
    var songMeta = Json.parse(Assets.getText(Paths.getPath("songs/"+curSong+"/meta"+shuffix+".json")));
    var songName = songMeta.displayName;
    var songArtist = songMeta.artists;
    
    var difficultyRaw = PlayState.difficulty?.toUpperCase();
    var difficultyDisplay = switch (difficultyRaw) {
        case "NORMAL": "[NORMAL]";
        case "EASY":   "[EASY]";
        case "HARD":   "[HARD]";
        default:       "[NORMAL]";
    }
    var diffColor = switch (difficultyRaw) {
        case "NORMAL": 0xFFFFFF00;
        case "EASY":   0xFF00FF00;
        case "HARD":   0xFFFF0000;
        default:       FlxColor.WHITE;
    }

    camCard = new FlxCamera();
    camCard.bgColor = FlxColor.TRANSPARENT;
    FlxG.cameras.add(camCard, false);

    group = new FlxTypedSpriteGroup();
    group.camera = camCard;

    // 歌名：字体 40（较大）
    songNameText = new FlxText(0, 0, 0, songName, 30);
    songNameText.setFormat(Paths.font("Tardling-Outline.ttf"), 30, FlxColor.WHITE, "left");
    songNameText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
    songNameText.antialiasing = Options.antialiasing;
    
    // 难度：字体 40，与歌名同行右侧
    difficultyText = new FlxText(0, 0, 0, difficultyDisplay, 30);
    difficultyText.setFormat(Paths.font("Tardling-Outline.ttf"), 30, diffColor, "right");
    difficultyText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
    difficultyText.antialiasing = Options.antialiasing;
    
    // 作曲家：字体 30（比歌名小，但比原来大）
    composerText = new FlxText(0, 0, 0, "Artists: " + songArtist, 20);
    composerText.setFormat(Paths.font("Tardling-Outline.ttf"), 20, FlxColor.WHITE, "left");
    composerText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
    composerText.antialiasing = Options.antialiasing;

    var padding = 15;
    var lineSpacing = 2;   // 紧挨歌名下方
    
    // 计算卡片宽度
    var titleSpacing = 5;   // 歌名与难度之间的间距（原来为20，现改为5，更紧凑）
    var firstRowWidth = songNameText.width + titleSpacing + difficultyText.width;
    var secondRowWidth = composerText.width;
    var cardWidth = Math.max(firstRowWidth, secondRowWidth) + padding * 2;
    
    var currentY = padding;
    songNameText.setPosition(padding, currentY);
    difficultyText.setPosition(padding + cardWidth - padding * 2 - difficultyText.width, currentY);
    
    currentY += songNameText.height + lineSpacing;
    composerText.setPosition(padding, currentY);
    currentY += composerText.height + padding;
    
    var cardHeight = currentY;
    
    background = new FlxSprite(0, 0).makeGraphic(Math.ceil(cardWidth), Math.ceil(cardHeight), FlxColor.BLACK);
    background.alpha = 0.5;
    group.add(background);
    
    group.add(songNameText);
    group.add(difficultyText);
    group.add(composerText);
    
    group.screenCenter(FlxAxes.Y);
    group.x = -group.width;
    add(group);

    for (event in events) {
        if (event.name == "songCard") {
            calledByEvent = true;
            break;
        }
    }
}

function onSongStart() {
    if (calledByEvent) return;
    showCard();
}

function onEvent(event) {
    if (event.event.name == "songCard") showCard();
}

function showCard() {
    FlxTween.tween(group, {x: 0}, 1, {ease: FlxEase.quintOut});
    new FlxTimer().start(2.5, (_) -> {
        FlxTween.tween(group, {x: -group.width}, 1, {ease: FlxEase.quintIn, onComplete: () -> {
            remove(group);
        }});
    });
}