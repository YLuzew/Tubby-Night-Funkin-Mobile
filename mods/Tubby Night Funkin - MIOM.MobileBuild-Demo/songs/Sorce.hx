import flixel.text.FlxTextBorderStyle;

// 仅修改得分、失误、精确率的显示样式和位置，不处理时间文本，不改变颜色
function postCreate() {
PauseSubState.script = "data/states/TNFPause.hx";
    for (txt in [scoreTxt, missesTxt, accuracyTxt]) {
        txt.setFormat(Paths.font("Tardling-Outline.ttf"), 18);
        txt.borderStyle = FlxTextBorderStyle.OUTLINE;
        txt.borderSize = 2;
        txt.borderColor = 0xFF000000;
        txt.antialiasing = true;
        txt.textField.antiAliasType = "advanced"; // 开启高级抗锯齿
        txt.textField.sharpness = 0;            // 最大清晰度
        add(txt);
    }
}