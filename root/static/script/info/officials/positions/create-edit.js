/**
 *  Handle form fields
 *
 */
$(document).ready(function() {
  /*
    Focus on the first available field
  */
  if ( $("#position_name").val() === "" ) {
    $("#position_name").focus();
  } else if ( $("#position_before").val() === "" ) {
    $("#position_before").trigger("chosen:activate");
  } else if ( $("#position_holders").val() === "" ) {
    $("#position_holders").focus();
  } else {
    // Default back to position name
    $("#position_name").focus();
  }
});