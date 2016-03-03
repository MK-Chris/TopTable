/**
 *  Handling form fields on the ranking template creation page
 * 
 *
 */

$(document).ready(function() {
  /*
    If the 'assign_points' field is ticked, enable the points value boxes, otherwise disable and blank them.
  */
  $("#assign_points").on("change", function() {
    if ( $(this).prop("checked") ) {
      $("input.points_awarded").prop("disabled", false);
    } else {
      $("input.points_awarded").val("");
      $("input.points_awarded").prop("disabled", true);
    }
  });
  
  /*
    Focus on first available field
  */
  if ( $("#name").val() == "" ) {
    $("#name").focus();
  } else if ( $("#assign_points").prop("checked") ) {
    // Can only focus on these fields if 'assign_points' is ticked
    if ( $("#points_per_win").val() === "" ) {
      $("#points_per_win").focus();
    } else if ( $("#points_per_draw").val() === "" ) {
      $("#points_per_draw").focus();
    } else if ( $("#points_per_loss").val() === "" ) {
      $("#points_per_loss").focus();
    } else {
      // Default back to name
      $("#name").focus();
    }
  } else {
    // Default back to name
    $("#name").focus();
  }
});