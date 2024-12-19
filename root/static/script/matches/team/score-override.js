/**
 *  Handle form fields
 *
 */
$(document).ready(function() {
  /*
    Focus on the first available field
  */
  if ( $("#override_score").prop("checked") ) {
    if ( $("home_team_match_score_override").val() === "" ) {
      $("#home_team_match_score_override").focus();
    } else if ( $("away_team_match_score_override").val() === "" ) {
      $("#away_team_match_score_override").focus();
    } else {
      $("#home_team_match_score_override").focus();
    }
  }
  
  set_score_fields();
  $("#override_score").on("change", set_score_fields);
  
  /*
    Enable / disable text fields based on the checked value of the cancel checkbox
  */
  function set_score_fields() {
    if ( $("#override_score").prop("checked") ) {
      // Show score fields
      $("#scores").show();
    } else {
      // Show scores fields and blank the values
      $("#scores").hide();
      $("#home_team_match_score_override").val("");
      $("#away_team_match_score_override").val("");
    }
  }
});