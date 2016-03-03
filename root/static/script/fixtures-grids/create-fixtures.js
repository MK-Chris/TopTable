/**
 *  Handle form fields
 *
 *
 */
$(document).ready(function() {
  /*
    Disable the options in subsequent select boxes once they've been selected in one
  */
  /*$("select").on("change", function() {
    // Get the select list we've changed, the value of the selected option and the week number
    var $select = $(this);
    var value   = $select.val();
    var week    = $select.data("week");
    
    // Get a list of selects after this one
    var $selects = $("select").filter(function(index) {
      return $(this).data("week") > week;
    });
    
    // Loop through all of the selects we filtered
    $selects.each(function(index) {
      // Now find all the options in the current select with a value less than or equal to the selected value
      var id = $(this).prop("id");
      
      // Loop through the options
      var $options  = $("#" + id + " option").filter(function() {
        return $(this).val() <= value;
      });
      
      // Finally loop through and disable the options
      $options.each(function(index) {
        $(this).prop("disabled", true);
      });
      
      // Update the Chosen plugin
      $(this).trigger("chosen:updated");
    });
  });*/
  
  /*
    Focus on the first field (we may move this into a server side script to detect which week is
    the first blank one later on - unsure at the moment whether it's worth the extra processing)
  */
  $("#week_1").trigger("chosen:activate");
});