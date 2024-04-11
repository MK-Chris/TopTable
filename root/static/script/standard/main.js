/**
 *  All the functions that we need on every page, or at least most pages.
 *   
 */
$(document).ready(function(){
  /* Nav menu */
  $("#main-menu").smartmenus({markCurrentItem: true}).find('> li:first > a').removeClass('current');
  
  /*
    jQueryUI buttons
  */
  $("input[type=submit]:not(.button-approve, .button-deny, .button-reset), input[type=button]:not(.button-approve, .button-deny, .button-reset), button:not(.dt-paging-button)").button();
  
  /*
   Active / inactive input fields
  */
  $("form").on("focus", "input, textarea", function() {
    $(this).addClass("active");
  });
  
  $("form").on("blur", "input, textarea", function() {
    $(this).removeClass("active");
  });
  
  /*
    Select all text on click (except the 'Chosen' plugin's search box, otherwise this will select the first letter when we start typing, which will then delete it when we carry on typing)
  */
  $("input[type='text'], input[type='number'], input[type='email'], input[type='url'], input[type='date'], input[type='search'], input[type='tel']").not("div.chosen-search input").on("focus", function () {
    $(this).select();
  });
  
  /*
    Scroll to top
  */
  if ($('#back-to-top').length) {
    var scrollTrigger = 100; // px
    var backToTop = function () {
      var scrollTop = $(window).scrollTop();
      if (scrollTop > scrollTrigger) {
        $("#back-to-top").addClass("show");
      } else {
        $("#back-to-top").removeClass("show");
      }
    };
    
    backToTop();
    
    $(window).on("scroll", function () {
        backToTop();
    });
    
    $("#back-to-top").on("click", function (e) {
        e.preventDefault();
        $("html,body").animate({
            scrollTop: 0
        }, 700);
    });
}
  
  /*
    Modal AJAX loading image
  */
  /*$(document).ajaxStart(function() {
    $("body").addClass("loading");
  });
  
  $(document).ajaxStop(function() {
    $("body").removeClass("loading");
  });*/
});