$(document).ready(function(){
  /*
    Focus on the correct field
  */
  if ( $("#name").val() == "" ) {
    $("#name").focus();
  } else if ( $("#club").val() == "" ) {
    $("#club").focus();
    $("#club").trigger("chosen:activate");
  } else if ( $("#division").val() == "" ) {
    $("#division").focus("chosen:activate");
  } else if ( $("#home_night").val() == "" ) {
    $("#home_night").trigger("chosen:activate");
  }
});