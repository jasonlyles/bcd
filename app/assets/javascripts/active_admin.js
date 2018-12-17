//= require active_admin/base
//= require activeadmin_addons/all
// = require active_material

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

$(function() {
  function readURL(input, previewImg) {
    if (input.files && input.files[0]) {
      var reader = new FileReader();

      reader.onload = function(e) {
        previewImg.attr('src', e.target.result);
      }
      reader.readAsDataURL(input.files[0]);
    }
  }

  // resets the value to address browsing a 2nd time for a different file
  $('fieldset.inputs').on('click touchstart', '.nested-images-upload', function() {
    $(this).val('');
  });

  //Trigger now when you have selected any file
  $('fieldset.inputs').on('change', '.nested-images-upload', function() {
    previewImg = $('.img-preview').last();
    previewImg.removeClass('hidden');
    readURL(this, previewImg);
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
