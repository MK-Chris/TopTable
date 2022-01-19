/**
 *  Handle form fields
 *
 */
$(document).ready(function() {
  /*
    Focus on the first available field
  */
  if ( $("#banned_id").val() == "" ) {
    $("#banned_id").focus();
  } else if ( $("#expires_date").val() === "" ) {
    $("#expires_date").focus();
  } else if ( $("#expires_hour").val() === "" ) {
    $("#expires_hour").trigger("chosen:activate");
  } else if ( $("expires_minute").val() === "" ) {
    $("#expires_minute").trigger("chosen:activate");
  } else {
    // Default back to full name
    $("#banned_id").focus();
  }
});
