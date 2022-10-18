// TODO:
// * Would still like to figure out a nice way to scroll to BL XML textarea and bad wanted list id warning

// in onclick of 'Assemble BrickLink XML' button, entry-way into the main functionality of this script
function findNeededParts() {
  var stillNeededParts = [];
  inputArray = document.getElementsByClassName('part-quantity');
  for (var i = 0; i < inputArray.length; i++) {
    var qtyNeeded = inputArray[i].value;
    if (qtyNeeded > 0) {
      var id_parcels = inputArray[i].id.split('_');
      var partNumber = id_parcels[1];
      var partColor = id_parcels[2];
      var partArray = [partNumber, partColor, qtyNeeded];
      stillNeededParts.push(partArray);
    }
  }
  var wantedList = '';
  var partsCondition = '';
  var wantedListValue = document.getElementById('custom_wanted_list').value
  if (wantedListValue != '' && isNumber(wantedListValue)) {
    if (hasClass(document.getElementById('bad_wanted_list_id'), 'd-none')) {} else {
      document.getElementById('bad_wanted_list_id').classList.add('d-none');
      var textField = document.getElementById('custom_wanted_list');
      textField.classList.remove('is-invalid');
    }
    wantedList = wantedListValue;
  } else if (wantedListValue != '' && isNumber(wantedListValue) == false) {
    document.getElementById('bad_wanted_list_id').classList.remove('d-none');
    sendUserToWantedListTextField();
    return;
  }
  if (document.getElementById('part_condition_new').checked) {
    partsCondition = 'new';
  } else if (document.getElementById('part_condition_either').checked) {
    partsCondition = 'either';
  }
  xml = assembleXml(stillNeededParts, wantedList, partsCondition);
  updateXmlField(xml);
  sendUserToXml();
}

function hasClass(el, cssClass) {
  return el.className && new RegExp("(^|\\s)" + cssClass + "(\\s|$)").test(el.className);
}

function isNumber(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}

// Use the parts array based on the current values of the lots' quantity fields
// to assemble the BL XML
function assembleXml(partsArray, wantedList, partsCondition) {
  var xml = "<INVENTORY>\n";
  var options = '';
  if (wantedList != '') {
    options += "<WANTEDLISTID>" + wantedList + "</WANTEDLISTID>\n"
  }

  if (partsCondition == 'new') {
    options += "<CONDITION>N</CONDITION>\n"
  }
  for (i = 0; i < partsArray.length; i++) {
    xml += "<ITEM>\n<ITEMTYPE>P</ITEMTYPE>\n" + options + "<ITEMID>" + partsArray[i][0] + "</ITEMID>\n<COLOR>" + partsArray[i][1] + "</COLOR>\n<MINQTY>" + partsArray[i][2] + "</MINQTY>\n</ITEM>\n"
  }
  xml += "</INVENTORY>\n"
  return xml;
}

// use the passed-in xml to update the textarea where users can copy BL xml from
function updateXmlField(xml) {
  var blDiv = document.getElementById('bricklinkXmlDiv');
  blDiv.className -= 'hidden';
  var textArea = document.getElementById('bricklinkXml');
  textArea.value = xml;
}

function sendUserToXml() {
  var textField = document.getElementById('bricklinkXml');
  textField.focus();
  textField.select();
}

function sendUserToWantedListTextField() {
  var textField = document.getElementById('custom_wanted_list');
  textField.select();
  textField.focus();
  textField.classList.add('is-invalid');
}

// called in onclick on BL XML textarea
function select_all_text(element) {
  var textField = document.getElementById(element.id);
  textField.focus();
  textField.select();
}

// called in the onBlur in the row quantity text fields
function toggleRowHighlighting(element) {
  id_parcels = element.id.split('_');
  var tableRowId = id_parcels[1] + '_' + id_parcels[2];
  if (element.value === 0 || element.value === '0') {
    if (!document.getElementById(tableRowId).classList.contains('lot-quantity-zero')) {
      document.getElementById(tableRowId).classList.add('lot-quantity-zero');
    }
  } else {
    document.getElementById(tableRowId).classList.remove('lot-quantity-zero');
  }
}

// called by button at top of parts list to toggle visibility of highlighted 'complete' rows
function toggleCompletedVisibility(element) {
  var lotRows = document.getElementsByClassName('lot-quantity-zero');

  if (element.textContent === ' Hide Completed Rows') {
    element.innerHTML = "<i class=\"far fa-eye\"></i> Show Completed Rows"
    for (var i = 0; i < lotRows.length; i++) {
      lotRows[i].classList.add('d-none');
    }
  } else {
    element.innerHTML = "<i class=\"far fa-eye-slash\"></i> Hide Completed Rows"
    for (var i = 0; i < lotRows.length; i++) {
      lotRows[i].classList.remove('d-none');
    }
  }
}

// called by 'Save form values' button
function saveForm() {
  var parts = {};
  inputArray = document.getElementsByClassName('part-quantity');
  for (var i = 0; i < inputArray.length; i++) {
    var qtyNeeded = inputArray[i].value;
    var userHas = inputArray[i].max - qtyNeeded;
    var id_parcels = inputArray[i].id.split('_');
    var partNumber = id_parcels[1];
    var partColor = id_parcels[2];
    var key = partNumber + '_' + partColor;
    parts[key] = userHas;
  }

  $.ajax({
    dataType: "json",
    data: {
      values: JSON.stringify(parts)
    },
    cache: false,
    type: 'PUT',
    url: '/user_parts_lists/' + partsListId,
    error: function(XMLHttpRequest, errorTextStatus, error) {
      location.reload();
    },
    success: function(data) {
      location.reload();
    }
  });
}

// Clear out the users store parts list and reload the page, called by 'Reset form values' button
function clearStorageAndReloadPage() {
  var r = confirm('Are you sure you want to clear the form?');
  if (r == true) {
    $.ajax({
      dataType: "json",
      data: {
        values: '{}'
      },
      cache: false,
      type: 'PUT',
      url: '/user_parts_lists/' + partsListId,
      error: function(XMLHttpRequest, errorTextStatus, error) {
        location.reload();
      },
      success: function(data) {
        location.reload();
      }
    });
  }
}
