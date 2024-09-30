"use strict";
/**
 *  Handle form fields
 *
 */
$(document).ready(function() {
  /*
    Focus on the first available field
  */
  if ( $("#group_name").val() == "" ) {
    $("#group_name").focus();
  } else if ( $("#fixtures_grid").val() === "" ) {
    $("#fixtures_grid").trigger("chosen:activate");
  } else {
    // Default back to name
    $("#group_name").focus();
  }
  
  $("#manual_fixtures").on("change", function() {
    if ( $(this).prop("checked") ) {
      // Manually set fixtures, hide fixtures grid field and clear its selection
      $("#group-grid-container").hide();
      $("#fixtures_grid").val("");
      $("#fixtures_grid").trigger("chosen:updated");
    } else {
      $("#group-grid-container").show();
    }
  });
});
