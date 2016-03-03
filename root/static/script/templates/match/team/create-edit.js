/**
 *  Handle form fields on the individual match template create / edit page
 *
 */
$(document).ready(function() {
  /*
    Focus on first available field
  */
  if ( $("#name").val() == "" ) {
    $("#name").focus();
  } else if ( $("#singles_players_per_team").val() === "" ) {
    $("#singles_players_per_team").focus();
  } else if ( $("#winner_type").val() === "" ) {
    $("#winner_type").trigger("chosen:activate");
  } else {
    // Default back to name
    $("#name").focus();
  }
});