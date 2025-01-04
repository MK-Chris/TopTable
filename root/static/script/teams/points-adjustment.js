$(document).ready(function(){
  /*
    Focus on the correct field
  */
  if ( $("#action").val() == "" ) {
    $("#action").focus();
    $("#action").trigger("chosen:activate");
  } else if ( $("#points_adjustment").val() == "" ) {
    $("#points_adjustment").focus();
  } else if ( $("#reason").val() == "" ) {
    $("#reason").focus();
  } else {
    $("#points_adjustment").focus();
  }
});