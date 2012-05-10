$(function() {
 // Handler for .ready() called.
	$('#myTab').click(function(e){
		e.stopPropagation();
		$('.dropdown-menu').css('display','block');
	})
	
	$('body').click(function(){
		if($('.dropdown-menu').is(':visible')){
			$('.dropdown-menu').css('display','none');
		}
	})
});