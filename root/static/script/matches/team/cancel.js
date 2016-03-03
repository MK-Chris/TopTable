/**
 *  Handle form fields
 *
 */
$(document).ready(function() {
  /*
    Focus on the first available field
  */
  if ( $("#cancel").prop("checked") ) {
    if ( $("home_points_awarded").val() === "" ) {
      $("#home_points_awarded").focus();
    } else if ( $("away_points_awarded").val() === "" ) {
      $("#away_points_awarded").focus();
    } else {
      $("#home_points_awarded").focus();
    }
  }
  
  
  set_points_fields();
  $("#cancel").on("change", set_points_fields);
  
  /*
    Enable / disable text fields based on the checked value of the cancel checkbox
  */
  function set_points_fields() {
    if ( $("#cancel").prop("checked") ) {
      $("#home_points_awarded").prop("disabled", false);
      $("#away_points_awarded").prop("disabled", false);
    } else {
      $("#home_points_awarded").val(0);
      $("#away_points_awarded").val(0);
      $("#home_points_awarded").prop("disabled", true);
      $("#away_points_awarded").prop("disabled", true);
    }
  }
});