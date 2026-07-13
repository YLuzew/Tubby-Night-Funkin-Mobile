var Xpy = 0;//整体xy偏移
var Ypy = 0;

var comboNumberXpy = -100;//Combo中心点X偏移
var comboNumberYpy = 0;

var ratingXpy = 0;//判定xy偏移
var ratingYpy = -12;

var Comboshowtime = 0.5;//显示持续时间
var ratingshowtime = 0.5;
var comboSpacing = -10; // 数字之间的间距，可自定义设置
// 已移除着色器相关变量和开关

function onPlayerHit(e) {
    if(e.note.isSustainNote)
        return;

    e.showRating = false;

    var pre:String = e != null ? e.ratingPrefix : "";
    var suf:String = e != null ? e.ratingSuffix : "";

    // 先计算combo数字组的总宽度
    var separatedScore:String = CoolUtil.addZeros(Std.string(combo + 1), 3);
    
    // 计算combo数字组的总宽度
    var totalComboWidth:Float = 0;
    var numWidths:Array<Float> = []; // 存储每个数字的宽度
    
    // 计算每个数字的宽度
    for(i in 0...separatedScore.length) {
        var numScoreTemp:FlxSprite = new FlxSprite();
        CoolUtil.loadAnimatedGraphic(numScoreTemp, Paths.image(pre + 'num' + separatedScore.charAt(i) + suf));
        if (e != null) {
            numScoreTemp.scale.set(e.numScale * 1.25, e.numScale * 1.25);
        }
        numScoreTemp.updateHitbox();
        numWidths.push(numScoreTemp.width);
        totalComboWidth += numScoreTemp.width;
        numScoreTemp.destroy();
    }
    
    // 加上间距
    if(separatedScore.length > 1) {
        totalComboWidth += comboSpacing * (separatedScore.length - 1);
    }
    
    // 计算combo数字组的中心点x坐标
    var comboCenterX:Float = comboGroup.x + 190 + comboNumberXpy;
    var comboStartX:Float = comboCenterX - (totalComboWidth / 2);
    
    // 创建并显示判定（无着色器）
    var rating:FlxSprite = comboGroup.recycleLoop(FlxSprite);
    // 已移除着色器设置
    
    // 设置判定位置，使其x中心与combo数字组的中心点对齐
    CoolUtil.resetSprite(rating, comboCenterX, comboGroup.y + 25);
    CoolUtil.loadAnimatedGraphic(rating, Paths.image(pre + e.rating + suf));
    rating.acceleration.y = 550;
    rating.velocity.y -= FlxG.random.int(140, 175);
    rating.velocity.x -= FlxG.random.int(0, 10);
    if (e != null) {
        rating.scale.set(e.ratingScale * 1.15, e.ratingScale * 1.15);
        rating.antialiasing = e.ratingAntialiasing;
    }
    rating.updateHitbox();
    
    // 调整判定位置，使其中心点对准目标位置
    rating.x -= rating.width / 2;
    rating.y -= rating.height / 2;
    rating.x += Xpy + ratingXpy;
    rating.y += Ypy + ratingYpy;

    FlxTween.tween(rating, {'scale.x': e.ratingScale * 0.95, 'scale.y': e.ratingScale * 0.95}, Conductor.crochet * 0.001, {ease: FlxEase.cubeOut});

    FlxTween.tween(rating, {alpha: 0}, ratingshowtime, {
        startDelay: Conductor.crochet * 0.0004,
        onComplete: function(tween:FlxTween) {
            rating.kill();
        }
    });

    // 创建并显示combo数字（无着色器）
    var numScores:Array<FlxSprite> = [];
    var currentX:Float = comboStartX;
    
    // 从左向右放置数字（百位、十位、个位）
    for(i in 0...separatedScore.length) {
        var numScore:FlxSprite = comboGroup.recycleLoop(FlxSprite);
        // 已移除着色器设置
        
        CoolUtil.loadAnimatedGraphic(numScore, Paths.image(pre + 'num' + separatedScore.charAt(i) + suf));
        CoolUtil.resetSprite(numScore, 0, 0);
        
        if (e != null) {
            numScore.antialiasing = e.numAntialiasing;
            numScore.scale.set(e.numScale * 1.25, e.numScale * 1.25);
        }
        numScore.updateHitbox();
        
        // 设置数字位置
        numScore.x = currentX;
        numScore.y = comboGroup.y + 80;
        
        // 应用整体偏移
        numScore.x += Xpy + comboNumberXpy;
        numScore.y += Ypy + comboNumberYpy + comboNumberYpy;
        
        numScore.acceleration.y = FlxG.random.int(200, 300);
        numScore.velocity.y -= FlxG.random.int(140, 160);
        numScore.velocity.x = FlxG.random.float(-5, 5);
        
        FlxTween.tween(numScore, {'scale.x': e.numScale * 0.95, 'scale.y': e.numScale * 0.95}, Conductor.crochet * 0.001, {ease: FlxEase.cubeOut});

        FlxTween.tween(numScore, {alpha: 0}, Comboshowtime, {
            onComplete: function(tween:FlxTween) {
                numScore.kill();
            },
            startDelay: Conductor.crochet * 0.0009
        });
        
        // 更新下一个数字的X位置，加上间距
        currentX += numWidths[i] + comboSpacing;
        
        numScores.push(numScore);
    }
}

// 已移除 update 函数（原用于更新着色器时间，不再需要）
