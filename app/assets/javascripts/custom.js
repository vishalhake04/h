/*
Template Name: Quickstart- HTML template for business
Author: Themehappy
Version: 1.0
*/


(function ($) {
	'use strict';

	jQuery(document).ready(function ($) {

		/* -- Preloader Js -- */

        $(window).on("load", function () {
            $('.spinner').fadeOut();
            $('.preloader-area').delay(350).fadeOut('slow');
        });


		/* -- Sticky Menu -- */


		$(window).on('scroll', function () {
			if ($(window).scrollTop() > 50) {
				$('.navbar-fixed-top').addClass('sticky');
			} else {
				$('.navbar-fixed-top').removeClass('sticky');
			}
		});
	

		/* -- Wow -- */

		var wow = new WOW({
			mobile: false
		});
		wow.init();

		/* -- Slider Carousel -- */


		$(".slider-active").owlCarousel({
			items: 1,
			dots: false,
			autoplay: false,
			loop: true,
			mouseDrag: false,
			touchDrag: false,
			navText: ["<i class='fa fa-angle-double-left'></i>", "<i class='fa fa-angle-double-right'></i>"],
			responsive: {
				0: {
					items: 1
				},
				600: {
					items: 1
				},
				1000: {
					items: 1,
					nav: true,
				}
			}
		});

		/* -- about Carousel -- */

		$(".about-slider").owlCarousel({
        	items:1,
        	loop:true,
        	dots:true,
        	nav:false,
        	autoplay:false,

        });

		/* -- testimonial Carousel -- */
		$("#testimonial-slider").owlCarousel({
	        items:2,
	        pagination:true,
	        navigationText:["",""],
	        slideSpeed:1000,
	        autoPlay:true,
			responsive:{
					0:{
						items:1
					},
					600:{
						items:1
					},
					1000:{
						items:2
					}
				}			
	    });

		/* -- Smoth Scrool Js -- */

		$(".navbar-nav").on('click', 'a', function(e){
			var anchor = $(this);
			$('html, body').stop().animate({
				scrollTop: $(anchor.attr('href')).offset().top - 5
			}, 1000);
			e.preventDefault();
		});
		
		// Mobile Menu hiddin on click  
		
		$(".navbar-nav").on('click', 'a', function(){
			$(".navbar-collapse").removeClass("in");
		})			

		/* -- Bottom to Top -- */

		$('body').append('<div id="scrollup"><i class="fa fa-angle-up"></i></div>');
	
		
		 $(window).on("scroll", function () {
            if ($(this).scrollTop() > 250) {
                $('#scrollup').fadeIn();
            } else {
                $('#scrollup').fadeOut();
            }
        });
        $('#scrollup').on("click", function () {
            $("html, body").animate({
                scrollTop: 0
            }, 800);
            return false;
        });
		



		/* -- Skill -- */
		
		$('.skillsection').bind('inview', function (event, visible, visiblePartX, visiblePartY) {
			if (visible) {
				$('.chart').easyPieChart({
					//your configuration goes here
					easing: 'easeOut',
					delay: 3000,
					barColor: '#3498db',
					trackColor: '#C2C0BE',
					scaleColor: false,
					lineWidth: 8,
					size: 140,
					animate: 2000,
					onStep: function (from, to, percent) {
						this.el.children[0].innerHTML = Math.round(percent);
					}

				});
				$(this).unbind('inview');
			}
		});

		/* -- Portfolio mixitup Js -- */
		

		$('.portfolio-inner').mixItUp();

		

		 /* -- Counter Down Js -- */
			$('.coundown_res').countdown('2018/01/02', function(event) {
				var $this = $(this);
				$this.find('#day').html(event.strftime('<span>%D</span>'));
				$this.find('#hour').html(event.strftime('<span>%H</span>'));
				$this.find('#month').html(event.strftime('<span>%M</span>'));
				$this.find('#second').html(event.strftime('<span>%S</span>'));
			});
		 /* -- End Counter Down Js -- */	
		
		/* -- Counter Up Js -- */
		$('.counter').counterUp();
		
		/* -- Magnific PopUp Js -- */
		$(".video-play-btn").magnificPopup({
            type:'video',
        });

		/* -- Magnific PopUp Js -- */

		$('.project-hover').magnificPopup({
		  delegate: 'a', // child items selector, by clicking on it popup will open
		  type: 'image'
		  // other options
		});

		var magnifPopup = function () {
			$('.port-popup').magnificPopup({
				type: 'image',
				removalDelay: 300,
				mainClass: 'mfp-with-zoom',
				gallery: {
					enabled: true
				},
				zoom: {
					enabled: true, // By default it's false, so don't forget to enable it

					duration: 300, // duration of the effect, in milliseconds
					easing: 'ease-in-out', // CSS transition easing function

					// The "opener" function should return the element from which popup will be zoomed in
					// and to which popup will be scaled down
					// By defailt it looks for an image tag:
					opener: function (openerElement) {
						// openerElement is the element on which popup was initialized, in this case its <a> tag
						// you don't need to add "opener" option if this code matches your needs, it's defailt one.
						return openerElement.is('img') ? openerElement : openerElement.find('img');
					}
				}
			});
		};
		// Call the functions 
		magnifPopup();
		/*----- End ------------*/

	});

})(jQuery);