/**
 *  Handle form fields
 *
 */
$(document).ready(function() {
  /*
    Focus on the first available field
  */
  if ( $("#headline").val() == "" ) {
    $("#headline").focus();
  } else if ( $("#article").val() === "" ) {
    $("#article").focus();
  } else {
    // Default back to headline
    $("#headline").focus();
  }
});