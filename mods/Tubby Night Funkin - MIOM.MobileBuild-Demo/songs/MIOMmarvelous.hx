import funkin.game.ComboRating;
if(FlxG.save.data.NFrating) {
         
var marvelousScore = 450;//修改得分 sick=300
public var MIOMmarvelousMode = true; //不要动，Mode设置
function onPlayerHit(event) {
    
    if (event.note.isSustainNote) return;
    
    // 计算击打偏移
    var noteDiff:Float = Math.abs(event.note.strumTime - Conductor.songPosition);
        
            // 模式0：直接根据时间偏移
            if (noteDiff <= hitWindow * 0.06) 
                event.rating = "marvelous";
                event.score = marvelousScore;
}
}
function update() {
if(FlxG.save.data.NFrating) {
MIOMmarvelousMode = true;
}
}
/**
⠀⠀⠀⠀⢠⡿⠛⢻⡆⣴⠿⠿⠻⣦⠀⠀⠀⠀⠀⠀⠀⠀⢸⡟⠛⠛⠛⠛⢻⡇⠀⠀⠀⠀⠀
⠀⠀⠀⢠⡟⠁⠀⠈⠿⠋⠀⠀⠀⢿⡄⠀⠀⠀⠀⠀⠀⠀⠸⣷⣦⠀⠀⣶⣾⡇⠀⠀⠀⠀⠀
⠀⠀⢀⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠸⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀
⠀⢀⣾⠃⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀
⢀⣼⠇⠀⠀⢀⣾⣧⣰⡿⣧⠀⠀⠀⢸⣇⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀
⣾⣇⠀⠀⢀⣾⠃⠘⠟⠀⢻⡆⠀⠀⠀⣿⡀⠀⠀⠀⠀⠀⢠⣤⣿⠀⠀⣿⣄⣀⡀⠀⠀⠀⠀
⠉⠙⠻⢶⡾⠃⠀⠀⠀⠀⠀⢿⣤⡶⠾⠛⠃⠀⠀⠀⠀⠀⣼⡏⠁⠀⠀⠈⠉⣿⡇⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠛⠛⠛⠻⠿⠿⠁⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⣶⣶⣶⣶⣶⣶⣶⣶⣦⣤⣤⣤⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⠀⠀⠀
⠀⢠⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⣿⠛⠛⢻⣦⡾⠉⠉⠉⣿⡀⠀⠀
⠀⢸⣿⠀⠀⢀⣄⣀⣀⣀⡀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⣼⠇⠀⠀⠈⠛⠁⠀⠀⠀⢸⣇⠀⠀
⠀⢸⡇⠀⠀⢸⡏⠉⠉⢹⣿⠀⠀⢠⣿⠀⠀⠀⠀⠀⢀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡄⠀
⠀⢸⡇⠀⠀⢸⣇⣀⣀⣸⣿⠀⠀⢸⡿⠀⠀⠀⠀⠀⣸⡇⠀⠀⢠⣄⠀⢀⣶⡄⠀⠀⠸⣧⠀
⠀⢸⡇⠀⠀⠈⠉⠉⠉⠉⠉⠀⠀⢸⡇⠀⠀⠀⠀⢀⣿⠀⠀⠀⣿⠙⢷⡾⠻⣷⠀⠀⠀⢹⡇
⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⢸⡇⠀⠀⣸⡇⠀⠀⠀⠀⢻⡆⠀⣀⣨⣿
⠀⠘⠛⠛⠻⠿⠿⠿⠿⠿⠿⠿⠿⠿⠇⠀⠀⠀⠀⠙⠛⠷⣦⣿⠀⠀⠀⠀⠀⠈⠿⠛⠋⠉⠀
 */