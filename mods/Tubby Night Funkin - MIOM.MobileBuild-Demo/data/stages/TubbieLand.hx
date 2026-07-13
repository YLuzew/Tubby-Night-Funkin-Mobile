function stepHit(curStep) {
	if (curSong == 'chill bill') {
		switch (curStep) {
			case 288 | 704:
				camZoomingInterval = 1;
			case 1088 | 2000:
				camZoomingInterval = 4;
			case 554 | 1088:
				camZoomingInterval = 2;
			case 553:
				strumLines.members[2].characters[0].alpha = 1;
				strumLines.members[2].characters[0].playAnim('voice-trumpet-pops-out');
			case 819: strumLines.members[2].characters[0].alpha = 0;
		}
	}
}