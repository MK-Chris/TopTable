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
  } else {
    $("#password").focus();
  }
});