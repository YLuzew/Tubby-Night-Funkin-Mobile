import funkin.game.scoring.RatingManager;
import funkin.game.scoring.HitWindowData;

function postCreate() {
	var windows = HitWindowData.getWindows(3);
	ratingManager.ratingData = [];
	ratingManager.initDefaultData(windows);
}