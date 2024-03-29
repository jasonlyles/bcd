jQuery(function($) {
  window.NestedFormEvents = function() {
    this.addFields = $.proxy(this.addFields, this);
    this.removeFields = $.proxy(this.removeFields, this);
  };

  NestedFormEvents.prototype = {
    addFields: function(e) {
      // Setup
      var link = e.currentTarget;
      var assoc = $(link).data('association'); // Name of child
      var blueprint = $('#' + $(link).data('blueprint-id'));
      var content = blueprint.data('blueprint'); // Fields template

      // Make the context correct by replacing <parents> with the generated ID
      // of each of the parent objects
      var context = ($(link).closest('.fields').closestChild('input, textarea, select').eq(0).attr('name') || '').replace(new RegExp('\[[a-z_]+\]$'), '');

      // context will be something like this for a brand new form:
      // project[tasks_attributes][1255929127459][assignments_attributes][1255929128105]
      // or for an edit form:
      // project[tasks_attributes][0][assignments_attributes][1]
      if (context) {
        var parentNames = context.match(/[a-z_]+_attributes/g) || [];
        var parentIds = context.match(/[0-9]+/g) || [];

        for (var i = 0; i < parentNames.length; i++) {
          if (parentIds[i]) {
            content = content.replace(new RegExp('(_' + parentNames[i] + ')_.+?_', 'g'), '$1_' + parentIds[i] + '_');

            content = content.replace(new RegExp('(\\[' + parentNames[i] + '\\])\\[.+?\\]', 'g'), '$1[' + parentIds[i] + ']');
          }
        }
      }

      // Make a unique ID for the new child
      var regexp = new RegExp('new_' + assoc, 'g');
      var new_id = new Date().getTime();
      content = content.replace(regexp, new_id);

      var field = this.insertFields(content, assoc, link);
      // bubble up event upto document (through form)
      field.trigger({type: 'nested:fieldAdded', field: field}).trigger({
        type: 'nested:fieldAdded:' + assoc,
        field: field
      });
      return false;
    },
    insertFields: function(content, assoc, link) {
      return $(content).insertBefore(link);
    },
    removeFields: function(e) {
      var $link = $(e.currentTarget),
        assoc = $link.data('association'); // Name of child to be removed

      var hiddenField = $link.prev('input[type=hidden]');
      hiddenField.val('1');

      var field = $link.closest('.fields');
      field.hide();

      field.trigger({type: 'nested:fieldRemoved', field: field}).trigger({
        type: 'nested:fieldRemoved:' + assoc,
        field: field
      });
      return false;
    }
  };

  window.nestedFormEvents = new NestedFormEvents();
  $(document).delegate('form a.add_nested_fields', 'click', nestedFormEvents.addFields).delegate('form a.remove_nested_fields', 'click', nestedFormEvents.removeFields);
});

// http://plugins.jquery.com/project/closestChild
/*
 * Copyright 2011, Tobias Lindig
 *
 * Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php)
 * and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
 *
 */
(function($) {
  $.fn.closestChild = function(selector) {
    // breadth first search for the first matched node
    if (selector && selector != '') {
      var queue = [];
      queue.push(this);
      while (queue.length > 0) {
        var node = queue.shift();
        var children = node.children();
        for (var i = 0; i < children.length; ++i) {
          var child = $(children[i]);
          if (child.is(selector)) {
            return child; //well, we found one
          }
          queue.push(child);
        }
      }
    }
    return $(); //nothing found
  };
})(jQuery);
