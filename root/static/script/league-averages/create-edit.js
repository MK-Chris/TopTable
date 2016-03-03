/**
 *  Handle form fields
 *
 */
$(document).ready(function() {
  /*
    Focus on the first available field
  */
  if ( $("#full_name").val() == "" ) {
    $("#full_name").focus();
  } else if ( $("#short_name").val() === "" ) {
    $("#short_name").focus();
  } else if ( $("#email_address").val() === "" ) {
    $("#email_address").focus();
  } else if ( $("#website").val() === "http://www." ) {
    $("#website").focus();
  } else if ( $("#start_hour").val() === "" ) {
    $("#start_hour").trigger("chosen:activate");
  } else if ( $("#start_minute").val() === "" ) {
    $("#start_minute").trigger("chosen:activate");
  } else if ( $("#venue").val() === "" ) {
    $("#venue").trigger("chosen:activate");
  } else if ( $("#token-input-secretary").val() === "" ) {
    $("#token-input-secretary").focus();
  } else {
    // Default back to full name
    $("#full_name").focus();
  }
});