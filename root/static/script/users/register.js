/**
 *  Handle form fields
 *
 */
$(document).ready(function(){
  /*
    Focus on the correct field
  */
  if ( $("#username").val() == "" ) {
    $("#username").focus();
  } else if ( $("#email_address").val() === "" ) {
    $("#email_address").focus();
  } else if ( $("#confirm_email_address").val() === "" ) {
    $("#confirm_email_address").focus();
  } else {
    $("#password").focus();
  }
});