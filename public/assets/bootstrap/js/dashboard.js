jQuery(document).ready(function(){
	
	"use strict";
	
	function showTooltip(x, y, contents) {
		jQuery('<div id="tooltip" class="tooltipflot">' + contents + '</div>').css( {
		  position: 'absolute',
		  display: 'none',
		  top: y + 5,
		  left: x + 5
		}).appendTo("body").fadeIn(200);
	}
    
   var uploads = [[0, 2], [1, 9], [2,5], [3, 13], [4, 6], [5, 13], [6, 8]];
	var downloads = [[0, 0], [1, 6.5], [2,4], [3, 10], [4, 2], [5, 10], [6, 4]];
	
	
	// Trigger Resize in Morris Chart
   var delay = (function() {
		var timer = 0;
		return function(callback, ms) {
			clearTimeout(timer);
			timer = setTimeout(callback, ms);
		};
    })();

   jQuery(window).resize(function() {
		delay(function() {
			m4.redraw();
	}, 100);
   }).trigger('resize');
    
   jQuery('#sparkline').sparkline([4,3,3,1,4,3,2,2,3,10,9,6], {
		  type: 'bar', 
		  height:'30px',
        barColor: '#428BCA'
   });
	
    
    jQuery('#sparkline2').sparkline([9,8,8,6,9,10,6,5,6,3,4,2], {
		  type: 'bar', 
		  height:'30px',
        barColor: '#999'
    });
    


    
});