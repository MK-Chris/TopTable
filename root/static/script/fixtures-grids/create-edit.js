/**
 *  Handle form fields
 *
 */
$(document).ready(function() {
  /*
    Focus on first available field
  */
  if ( $("#name").val() == "" ) {
    $("#name").focus();
  } else if ( $("#maximum_teams").val() === "" ) {
    $("#maximum_teams").focus();
  } else if ( $("#fixtures_repeated").val() === "" ) {
    $("#fixtures_repeated").focus();
  } else {
    // Default back to name
    $("#name").focus();
  }
});