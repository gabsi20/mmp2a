// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .


var ready = function() {
	$('#burger').click(function(){
		if($('.main_menu').css("display") == "none"){
			$('.main_menu').css("display","block");
			if(($(window).width() > 768)&&($(window).width() < 1200)){
				$('#content').removeClass("col-sm-12");
				$('#content').addClass("col-sm-8");
			}
		}
		else{
			$('.main_menu').css("display","none");
			if(($(window).width() > 768)&&($(window).width() < 1200)){
				$('#content').removeClass("col-sm-8");
				$('#content').addClass("col-sm-12");
			}
		}
	});
	var showinfo = function(){
		var a = $(this).attr("id");
		var check;
		if($('.singledetail[id="'+a+'"]').css("display") == "block"){
			$('.singledetail[id="'+a+'"]').css("display","none");
		}
		else{
			$('.singledetail').css("display","none");
			if($(window).width() > 768){
				$('.singledetail[id="'+a+'"]').css("display","block");
			}
			else{
				$(this).after($('.singledetail[id="'+a+'"]'));
				$('.singledetail[id="'+a+'"]').css("display","block");
			}
		}	
	}
	var close = function(){
		console.log("moterfugger");
	}
	$('#listlink').click(function(){
		$('#listlink_loader').css("display","inline");
	})
	$('.right_close').click(showinfo);
	$('.singletask').click(showinfo);
	$('.info').click(showinfo);
}


$(document).on('page:load', ready);
$(document).ready(ready);