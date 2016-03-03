/**
 *  Handle form fields
 *
 */
$(document).ready(function() {
  /*
    Focus on the first available field
  */
  if ( $("#type").val() == "" ) {
    $("#type").trigger("chosen:activate");
  } else if ( $("#venue").val() == "" ) {
    $("#venue").trigger("chosen:activate");
  } else if ( $("#date").val() === "" ) {
    $("#date").focus();
  } else if ( $("#start_hour").val() === "" ) {
    $("#start_hour").trigger("chosen:activate");
  } else if ( $("#start_minute").val() === "" ) {
    $("#start_minute").trigger("chosen:activate");
  } else {
    $("#token-input-attendees").focus();
  }
  
  /*
    Hide some fields based on the value of others
  */
  function hide_fields() {
    if ( $("#all_day").prop("checked") ) {
      $("#finish-time-container").slideUp(400);
    } else {
      $("#finish-time-container").slideDown(400);
    }
  }
  
  hide_fields();
  
  $("#all_day").on("change", hide_fields);
});