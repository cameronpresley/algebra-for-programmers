/***************************************************************************
   Copyright 2016 Emily Estes

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
***************************************************************************/
var slideshow = function() {
	var $divs = $('body > div');
	$divs.hide();
	var $currentPage = $divs.first();
	$currentPage.show();

	var slideMode = true;

	var nextSlide = function () {
		if($currentPage.next().length == 0) { return; }
		$currentPage.hide();
		$currentPage = $currentPage.next();
		$currentPage.show();
	};

	var prevSlide = function () {
		if($currentPage.prev().length == 0) { return; }
		$currentPage.hide();
		$currentPage = $currentPage.prev();
		$currentPage.show();
	}

	var x = 0;
	var y = 0;
	var dx = 0;
	var dy = 0;
	var started = false;
	var touchStart = function(evt) {
		started = true;
		x = evt.touches[0].clientX;
		y = evt.touches[0].clientY;
	};

	var touchMove = function(evt) {
		if(!started) { return; }
		var nx = evt.touches[0].clientX;
		var ny  = evt.touches[0].clientY;
		dx = x - nx;
		dy = y - ny;
	};

	var touchEnd = function(evt) {
		started = false;
		if (Math.abs(dx) > (1.8 * Math.abs(dy))) {
			if(dx > 0) {
				nextSlide();
			} else {
				prevSlide();
			}
		}
	}

	document.addEventListener('touchstart', touchStart, false);        
	document.addEventListener('touchmove', touchMove, false);
	document.addEventListener('touchend', touchEnd, false);

	$('body').keydown(function (evt) {
		if(evt.keyCode == 27) {
			if(slideMode) {
				slideMode = false;
				$divs.show();
			} else {
				slideMode = true;
				$divs.hide();
				$currentPage = $divs.first();
				$currentPage.show();
			}
		} else if(slideMode && (evt.keyCode == 37)) {
			// left
			prevSlide();
		} else if(slideMode && (evt.keyCode == 39)) {
			// right
			nextSlide();
		}
	});
};
