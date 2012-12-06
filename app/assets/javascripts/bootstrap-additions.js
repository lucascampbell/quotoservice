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
	$('.push_quote').click(function(){
		var href = this.href;
		var link = this;
		this.href = "#";
		this.innerHTML = "wait";
		$.ajax({
			url:href,
			type:"GET",
			dataType: "json",
			success:function(resp){
				$('.success_bar')[0].innerHTML = resp['text'];
				$('.success_bar').fadeIn(2000).fadeOut(3000);
				link.href = href;
				link.innerHTML = "push";
			},
			error:function(resp){
				$('.error_bar')[0].innerHTML = resp['text'];
				$('.error_bar').fadeIn(2000).fadeOut(3000);
				link.href = href;
				link.innerHTML = "push";
			}
		})
		return false;
	})
});