"use strict";
/**
 *  Handle form fields
 *
 */
$(document).ready(function() {
  /*
    Focus on the first available field
  */
  if ( $("#name").val() == "" ) {
    $("#name").focus();
  } else if ( $("#event_type").val() === "" ) {
    $("#short_name").trigger("chosen:activate");
  } else if ( $("#event_type").val() === "single-tournament" && $("#tournament_type").val() === "" ) {
    $("#tournament_type").trigger("chosen:activate");
  } else if ( $("#venue").val() === "" ) {
    $("#venue").trigger("chosen:activate");
  } else {
    // Default back to name
    $("#name").focus();
  }
  
  /*
    Sort out whether to show or hide the tournament details
  */
  handle_event_type();
  handle_team_tournaments();
  
  /*
    Show / hide tournament details based on the event type value when it changes
  */
  $("#event_type, #tournament_type").on("change", function() {
    handle_event_type();
    handle_team_tournaments();
  });
});

/*
  Show or hide the tournament details field based on the value of event_type (triggered on event_type change and also on initial load)
*/
function handle_event_type() {
  if ( $("#event_type").val() === "single-tournament" ) {
    $("#tournament-details-container").show();
  } else {
    $("#tournament-details-container").hide();
  }
}

/*
  Show or hide the venue / 
*/
function handle_team_tournaments() {
  if ( $("#event_type").val() === "single-tournament" && $("#tournament_type").val() === "team" ) {
    $("#venue-container").hide();
    $("#date-container").hide();
    $("#start-time-container").hide();
    $("#all-day-container").hide();
    $("#finish-time-container").hide();
  } else {
    $("#venue-container").show();
    $("#date-container").show();
    $("#start-time-container").show();
    $("#all-day-container").show();
    $("#finish-time-container").show();
  }
}