//= require jquery
//= require popper
//= require bootstrap
//= require jquery_ujs
//= require jquery.carousel
//= require nested_form
//= require easing
//= require_tree .

$(window).scroll(function() {
  if ($('.navbar').offset().top > 8) {
    $('.fixed-top').addClass('top-nav-collapse');
    $('#scroll-down').removeClass('d-lg-block');
    $('.navbar-toggler').addClass('white-navbar-toggler');
    $('.navbar-toggler-icon').addClass('white-navbar-toggler-icon');
  } else {
    $('.fixed-top').removeClass('top-nav-collapse');
    $('#scroll-down').addClass('d-lg-block');
    $('.navbar-toggler').removeClass('white-navbar-toggler');
    $('.navbar-toggler-icon').removeClass('white-navbar-toggler-icon');
  }
});

$(function() {
  $('[data-toggle="popover"]').popover()
})
/*
$(function() {
  $('.page-scroll a').bind('click', function(e) {
    var $anchor = $(this);
    $('html, body').stop().animate({
      scrollTop: $($anchor.attr('href')).offset().top
    }, 1500, 'easeInOutExpo');
    e.preventDefault();
  })
})
*/

/*
//This function is used in the products/new and edit pages to ajax-ily create a model code for the product
$(function() {
  $("#product_subcategory_id").change(function(){
    var id_value_string = $(this).val();
    if (id_value_string == "") {
      //do nothing!
    }
    else {
      //Send the request and update product_code text field
      $.ajax({
        dataType: "json",
        cache: false,
        url: '/subcategories/' + id_value_string + '/model_code.json',
        timeout: 2000,
        error: function(XMLHttpRequest, errorTextStatus, error){
          alert("Failed to submit : "+ errorTextStatus +" ;"+error);
        },
        success: function(data){
          $("#product_product_code").val(data);
        }
      });
    };
  });
});
*/
/*
$(function(){
    $('#alert_wrapper').delay(5000).queue(function(){
        $('#alert_message').replaceWith('K, bye');
        $(this).dequeue();
    });
    $('#alert_wrapper').delay(2000).fadeOut(1000);
});
*/
/* Replaced this method, but thought I'd leave it here briefly as reference for getting values from ID'd fields, and how to pick up a button click
$(document).ready(function(){
  $("#account_info_user_search_submit").click(function(event){
    var email = $("#account_info_user_email").val();
    alert("yo yo yo!"+ email);
    if (email == "") {
      alert("Must enter an email address!");
    }
    else {
      $.ajax({
        dataType: "json",
        cache: false,
        url: '/admin/'+email+'/find_user.json',
        timeout: 2000,
        error: function(XMLHttpRequest, errorTextStatus, error){
          alert("Failed to submit : "+ errorTextStatus+" ;"+error);
        },
        success: function(data){
          alert("He-yi!");
        }
      });
    };
  });
});
*/
