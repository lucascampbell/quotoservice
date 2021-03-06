$(function() {
 // Handler for .ready() called.
	$('#myTab').click(function(e){
		e.stopPropagation();
		$('.dropdown-menu').css('display','block');
	});
	$('body').click(function(){
		if($('.dropdown-menu').is(':visible')){
			$('.dropdown-menu').css('display','none');
		}
	});
	$('.email_confirm').click(function(){
		var answer = confirm('Should I send out a not accepted email?');
		if(answer){
			this.firstChild.href += "?mail=true";
		}
		else{
			this.firstChild.href += "?mail=false";
		}
		return true;
	});
	$('.push_quote_confirm').click(function(){
		var answer = confirm('Quote is above apple push limit and will be truncated.  Do you want to continue?');
		if(answer){
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
			});
		}
		return false;
	});
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
	$('.priority_edit').click(function(){
		var id = this.id;
		var klss = this.previousElementSibling.value;
		var priority = $('#priority_' + id ).val();
		$.ajax({ 
				url: '/push/edit_priority',
				type:"GET",
				data: {id:id,klss:klss,priority:priority}, 
				dataType: "json",
				success: function(resp){
					$('.success_bar')[0].innerHTML = resp['text'];
					$('.success_bar').fadeIn(2000).fadeOut(3000);
				},
				error: function(resp){
					$('.error_bar')[0].innerHTML = resp['text'];
					$('.error_bar').fadeIn(2000).fadeOut(3000);
				}
				
			});
	})
	$('.expires_date').datetimepicker({
		timeFormat: 'hh:mm z',
		dateFormat: 'dd-mm-yy'
	});
	$(".t_select").multiselect();
});

function NotesSubmit(d){
	var form = d.form;
	$.ajax({
		url: form.action,
		type:'GET',
		data: {id:form[3].value,quote_id:form[2].value},
		dataType: "json",
		success: function(resp){
				$('.success_bar')[0].innerHTML = resp['text'];
				$('.success_bar').fadeIn(2000).fadeOut(3000);
		}
	});
	return false;
}