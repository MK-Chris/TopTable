/**
 *  Handle form fields
 *
 */
$(document).ready(function() {
  /*
    Focus on the first available field
  */
  if ( $("#first_name").val() === "" ) {
    $("#first_name").focus();
  } else if ( $("#surname").val() === "" ) {
    $("#surname").focus();
  } else if ( $("#email_address").val() === "" ) {
    $("#email_address").focus();
  } else if ( $("#reason").val() === "" ) {
    $("#reason").trigger("chosen:activate");
  } else if ( $("#message").val() === "" ) {
    $("#message").focus();
  } else {
    $("#first_name").focus();
  }
});