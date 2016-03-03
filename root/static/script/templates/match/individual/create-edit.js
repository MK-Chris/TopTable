/**
 *  Handle form fields on the individual match template create / edit page
 *
 */
$(document).ready(function() {
  /*
   If the serve type is static, enable the 'number of serves' fields, otherwise disable
  */
  $("#serve_type").on("change", function() {
    if ( $(this).val() == "static") {
      $("#serves").prop("disabled", false);
      $("#serves_deuce").prop("disabled", false);
    } else {
      $("#serves").prop("disabled", true);
      $("#serves_deuce").prop("disabled", true);
      $("#serves").val("");
      $("#serves_deuce").val("");
    }
  });
  
  /*
    Focus on first available field
  */
  if ( $("#name").val() == "" ) {
    $("#name").focus();
  } else if ( $("#game_type").val() === "" ) {
    $("#game_type").trigger("chosen:activate");
  } else if ( $("#legs_per_game").val() === "" ) {
    $("#legs_per_game").focus();
  } else if ( $("#minimum_points_win").val() === "" ) {
    $("#minimum_points_win").focus();
  } else if ( $("#clear_points_win").val() === "" ) {
    $("#clear_points_win").focus();
  } else if ( $("#serve_type").val() === "" ) {
    $("#serve_type").trigger("chosen:activate");
  } else if ( $("#serves").val() === "" && $("#serve_type").val() === "static" ) {
    $("#serves").focus();
  } else if ( $("#serves_deuce").val() === "" && $("#serve_type").val() === "static" ) {
    $("#serves_deuce").focus();
  } else {
    // Default back to name
    $("#name").focus();
  }
});