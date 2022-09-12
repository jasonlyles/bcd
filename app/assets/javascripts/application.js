//= require jquery
//= require popper
//= require bootstrap
//= require jquery-ui/widgets/autocomplete
//= require jquery_ujs
//= require jquery.carousel
//= require nested_form
//= require easing
//= require_tree .

$(window).scroll(function() {
  var navBar = $('.navbar')[0];
  if (typeof navBar !== "undefined") {
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

// This anonymous function looks to see if there is a field with the field_with_errors
// class applied inside a tab that we need to jump to when the page reloads after
// an issue trying to save on the backend. This only applies to forms where some
// of the fields are in separate tabs.
$(function() {
  var tabs = $('.field_with_errors:first').closest('.tab-pane');

  if (typeof(tabs[0]) != 'undefined' && tabs[0] != null) {
    $('#myTab a[href="#' + tabs[0].id + '"]').tab('show');
  };
});

// This function adds jquery autocomplete magic to text fields that have autocomplete_select
// set to true in data
$(document).on('keypress', "[data-autocomplete-select='true']", function() {
  $(this).autocomplete({source: $(this).data('autocomplete-source'), minLength: 2});
});

// Handle one of the lot forms losing focus. Check to be sure the quantity field
// is not empty or set to '0'
$(document).on('mouseleave', "[data-lot-form='true']", function() {
  // If we only have 2 input elements, then we're dealing with an existing lot,
  // in which case we won't have the part select and hidden element ID fields
  if (this.getElementsByTagName('INPUT').length === 2) {
    var quantityField = this.getElementsByTagName('INPUT')[0];
    var elementValue = 'stub';
  } else if (this.getElementsByTagName('INPUT').length === 4) {
    // I don't like finding these elements by array index, but I don't know a way
    // to search through an HTMLCollection by data attribute
    var elementValue = this.getElementsByTagName('INPUT')[0].value;
    var quantityField = this.getElementsByTagName('INPUT')[2];
  }

  if (elementValue.length !== 0) {
    if (quantityField.value.length === 0 || quantityField.value === '0') {
      this.classList.add('border-2');
      this.classList.add('border-danger');
      quantityField.classList.add('border-danger');
    } else {
      this.classList.remove('border-2');
      this.classList.remove('border-danger');
      quantityField.classList.remove('border-danger');
    }
  }
});

// Handle a click on a element refresh button
$(document).on('click', "[data-element-refresh='true']", function() {
  var domElementId = $(this).data('element-dom-id');
  // Look for the color and part selects by id, using domElementId to assemble the IDs.
  // Then get the values, and call populateElementData
  var colorSelect = $('#parts_list_lots_attributes_' + domElementId + '_color')[0];
  var colorId = colorSelect.value;
  var partName = $('#parts_list_lots_attributes_' + domElementId + '_part').val();
  populateElementData(colorSelect, partName, colorId);
});

// This function is to take the part_name and color_id from the parts_list nested lots
// form, and convert it to an element_id, because that's what's actually stored in
// the lots record
$(document).on('change', "[data-element-select='true']", function() {
  var selectId = this.id;
  var selectType = selectId.substr(selectId.lastIndexOf("_") + 1);
  var colorId = '';
  var partName = ''

  if (selectType === 'color') {
    colorId = this.value;
    var partSelectId = selectId.replace('_color', '_part');
    partName = $('#' + partSelectId).val();
  } else {
    partName = this.value;
    var colorSelectId = selectId.replace('_part', '_color');
    colorId = $('#' + colorSelectId).val();
  }
  if (partName && colorId) {
    console.log('both populated!');
    var selectElement = this;
    populateElementData(selectElement, partName, colorId);
  }
});

function populateElementData(selectElement, partName, colorId) {
  if (!(partName && colorId)) {
    return nil;
  }
  // Make my ajax call
  $.ajax({
    dataType: "json",
    data: {
      part_name: partName,
      color_id: colorId
    },
    cache: false,
    type: 'POST',
    url: '/elements/find_or_create.json',
    context: selectElement,
    error: function(XMLHttpRequest, errorTextStatus, error) {
      alert("Failed to Update : " + errorTextStatus + " ; " + error);
    },
    success: function(data) {
      var elementImageWrapper = this.closest('section').children[0];
      elementImageWrapper.innerHTML = '';
      elementImageWrapper.classList.add('shadow-sm');
      elementImageWrapper.classList.add('p-2');
      if (data['image_processing'] === true) {
        elementImageWrapper.innerHTML = '<p>Image not ready</p>';
      } else if (data['image']['url'] == null) {
        elementImageWrapper.innerHTML = '<p>Image not available</p>';
      } else if (data['image']['thumb']['url'] == null) {
        var imageUrl = data['image']['url']
        var img = $('<img>');
        img.attr('src', imageUrl);
        img.attr('width', '100');
        img.appendTo(elementImageWrapper);
      } else {
        var imageUrl = data['image']['thumb']['url']
        var img = $('<img>');
        img.attr('src', imageUrl);
        img.attr('width', '100');
        img.appendTo(elementImageWrapper);
      }
      // create an action wrapper for the Edit link and Refresh button to go into
      var actionWrapper = $('<div class="pt-2"></div>');

      // append a refresh button for the element
      var domId = this.name.match(/\d+/)[0];
      var button = $('<div class="d-inline px-2"><button type="button" class="btn btn-primary" data-element-refresh="true" data-element-dom-id="' + domId + '"><i class="fa fa-share"></i></button></div>');
      button.appendTo(actionWrapper);

      // append an edit link for the element
      var link = $('<a href="/elements/' + data['id'] + '/edit" target="_blank">Edit</a>');
      link.appendTo(actionWrapper);

      actionWrapper.appendTo(elementImageWrapper);

      // prepend LDRAW IDs for help identifying parts/colors as being the correct one.
      var p = $('<sup>LDraw</sup><p class="font-weight-bold">Part ID: ' + data['part_ldraw_id'] + '<br/>Color ID: ' + data['part_ldraw_color_id'] + '</p>');
      p.prependTo(elementImageWrapper);
      // Now that the element is set, update the form to update a hidden element_id field.
      var hiddenElementId = this.closest('div#element-grouping').children[0];
      hiddenElementId.value = data['id'];
    }
  });
};

//This function is used in the products/new and edit pages to populate the subcategory dropdown based on the category selection
$(function() {
  $("#product_category_id").change(function() {
    var id_value_string = $(this).val();
    if (id_value_string === "") {
      // if the id is empty remove all the sub_selection options from being selectable and do not do any ajax
      $("#product_subcategory_id option").remove();
      var row = "<option value=\"" + "" + "\">" + "" + "</option>";
      $(row).appendTo("#product_subcategory_id");
    } else {
      // Send the request and update sub category dropdown
      $.ajax({
        dataType: "json",
        cache: false,
        url: '/categories/' + id_value_string + '/subcategories.json',
        timeout: 2000,
        error: function(XMLHttpRequest, errorTextStatus, error) {
          alert("Failed to submit : " + errorTextStatus + " ;" + error);
        },
        success: function(data) {
          // Clear all options from sub category select
          $("#product_subcategory_id option").remove();
          //put in a empty default line
          var row = "<option value=\"" + "" + "\">" + "Please Select" + "</option>";
          $(row).appendTo("#product_subcategory_id");
          // Fill sub category select
          $.each(data, function(i, j) {
            var row = $("<option/>").val(j.id).text(j.name);
            $(row).appendTo("#product_subcategory_id");
          });
        }
      });
    };
  });
});

function giftInstructions(user_id, product_id) {
  $.ajax({
    dataType: "json",
    data: {
      gift: {
        'user_id': user_id,
        'product_id': product_id
      }
    },
    cache: false,
    type: 'POST',
    url: '/gift_instructions.json',
    error: function(XMLHttpRequest, errorTextStatus, error) {
      alert("Failed to Update : " + errorTextStatus + " ; " + error);
    },
    success: function(data) {
      alert("Success!")
    }
  });
};

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
