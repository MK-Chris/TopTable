/**
 *  Handle form fields
 *
 *
 */
$(document).ready(function(){
  /*
    Handle ticking / unticking teams that have / haven't entered
  */
  $("form").on("change", "input[type=checkbox]", function(){
    var team_id = $(this).data("team-id");
    if ( $(this).prop("checked") == false ) {
      $("#team-div-" + team_id).slideUp(400);
    } else {
      $("#team-div-" + team_id).slideDown(400);
    }
    
    $("#home_night_" + $(this).data("team-id")).trigger("chosen:updated");
    $("#division_" + $(this).data("team-id")).trigger("chosen:updated");
    $("#club_" + $(this).data("team-id")).trigger("chosen:updated");
  });
  
  /*
    Handle showing / hiding inactive teams
  */
  $("form").on("click", "#active-toggle", function(){
    if ( $(this).val() == "Show inactive teams" ) {
      $(this).val("Hide inactive teams");
      $(".no-active-teams").hide();
      $(".team-inactive").show();
    } else {
      $(this).val("Show inactive teams");
      $(".team-inactive").hide();
      $(".no-active-teams").show();
    }
  });
});