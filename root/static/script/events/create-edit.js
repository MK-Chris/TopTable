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
    $("#event_type").trigger("chosen:activate");
  } else if ( $("#event_type").val() === "single_tournament" && $("#tournament_type").val() === "" ) {
    $("#tournament_type").trigger("chosen:activate");
  } else if ( $("#venue").val() === "" ) {
    $("#venue").trigger("chosen:activate");
  } else {
    // Default back to name
    $("#name").focus();
  }
  
  /*
    Loan players fields
  */
  $("#allow_loan_players").on("change", function() {
    var $allow_loan_players = $(this);
    
    if ( $allow_loan_players.prop("checked") ) {
      // Checked, re-enable the other fields
      $("#loan-players-nested-fields").show();
    } else {
      // Not checked, disable and uncheck / blank the other fields
      $("#loan-players-nested-fields").hide();
    }
  });
  
  /*
    Sort out whether to show or hide the tournament details
  */
  handle_event_type();
  handle_tournament_type();
  handle_round_type_fields();
  
  /*
    Show / hide tournament details based on the event type value when it changes
  */
  $("#event_type, #tournament_type").on("change", function() {
    handle_event_type();
    handle_tournament_type();
  });
  
  /*
    Show or hide the ranking template based on whether or not the first round is a group round
  */
  $("#round_group").on("change", function() {
    handle_round_type_fields();
  });
});

/*
  Show or hide the tournament details field based on the value of event_type (triggered on event_type change and also on initial load)
*/
function handle_event_type() {
  if ( $("#event_type").val() === "single_tournament" ) {
    $("#tournament-details-container").show();
  } else {
    $("#tournament-details-container").hide();
  }
}

/*
  Show or hide the venue / 
*/
function handle_tournament_type() {
  // Handle venue, date , time, entry online fields if we have a tournament of type team
  if ( $("#event_type").val() === "single_tournament" && $("#tournament_type").val() === "team" ) {
    $("#venue-container").hide();
    $("#date-container").hide();
    $("#start-time-container").hide();
    $("#all-day-container").hide();
    $("#finish-time-container").hide();
    $("#season-details").hide();
    $("#enter-online").hide();
    $("div.wb").show();
  } else {
    $("#venue-container").show();
    $("#date-container").show();
    $("#start-time-container").show();
    $("#all-day-container").show();
    $("#finish-time-container").show();
    $("#season-details").show();
    $("#enter-online").show();
    
    if ( $("#week_beginning").length ) {
      $("#week_beginning").prettyCheckable("uncheck");
    }
    
    $("div.wb").hide();
  }
  
  // If it's a tournament, handle the entry type and the match template field we'll show
  if ( $("#event_type").val() === "single_tournament" ) {
    // Single event tournament, show the first round options depending on the entry type show the correct template field
    $("#tournament-round-container").show();
    switch ( $("#tournament_type").val() ) {
      case "team":
        // Show team match template, hide individual
        // Tournament defaults and loan players
        $("#def-team-match-tpl-container").show();
        $("#def-ind-match-tpl-container").hide();
        $("#default_invididual_match_template").val("");
        $("#default_invididual_match_template").trigger("chosen:updated");
        $("#loan-player-rules").show();
        $("#game-forefeits").show();
        
        // First round
        $("#round-team-match-tpl-container").show();
        $("#round-ind-match-tpl-container").hide();
        $("#round_invididual_match_template").val("");
        $("#round_invididual_match_template").trigger("chosen:updated");
        break;
      case "singles":
      case "doubles":
        // Hide team match template, show individual
        // Tournament defaults and loan players
        $("#def-team-match-tpl-container").hide();
        $("#def-ind-match-tpl-container").show();
        $("#default_team_match_template").val("");
        $("#default_team_match_template").trigger("chosen:updated");
        $("#loan-player-rules").hide();
        $("#game-forefeits").hide();
        
        // First round
        $("#round-team-match-tpl-container").hide();
        $("#round-ind-match-tpl-container").show();
        $("#round_team_match_template").val("");
        $("#round_team_match_template").trigger("chosen:updated");
        break;
      default:
        // Nothing selected, hide all
        // Tournament defaults and loan players
        $("#def-team-match-tpl-container").hide();
        $("#def-ind-match-tpl-container").hide();
        $("#default_invididual_match_template").val("");
        $("#default_invididual_match_template").trigger("chosen:updated");
        $("#default_team_match_template").val("");
        $("#default_team_match_template").trigger("chosen:updated");
        $("#loan-player-rules").hide();
        $("#game-forefeits").hide();
        
        // First round
        $("#round-team-match-tpl-container").hide();
        $("#round-ind-match-tpl-container").hide();
        $("#round_team_match_template").val("");
        $("#round_team_match_template").trigger("chosen:updated");
        $("#round_invididual_match_template").val("");
        $("#round_invididual_match_template").trigger("chosen:updated");
        break;
    }
  } else {
    // Not a single-tournament event, hide all the tournament-related fields
    $("#tournament-round-container").hide();
    $("#tournament_type").val("");
    $("#tournament_type").trigger("chosen:updated");
    $("#def-team-match-tpl-container").hide();
    $("#def-ind-match-tpl-container").hide();
    $("#default_invididual_match_template").val("");
    $("#default_invididual_match_template").trigger("chosen:updated");
    $("#default_team_match_template").val("");
    $("#default_team_match_template").trigger("chosen:updated");
    $("#loan-player-rules").hide();
    $("#game-forefeits").hide();
  }
}

/* Show the group ranking if it's a group round, show the number of entrants if it's not */
function handle_round_type_fields() {
  if ( $("#round_group").prop("checked") ) {
    // Group round
    $("#round-group-rank-tpl-container").show();
    $("#round-of-container").hide();
    $("#round_of").val("");
  } else {
    // Straight knock-out
    $("#round-of-container").show();
    $("#round-group-rank-tpl-container").hide();
    $("#round_group_rank_template").val("");
    $("#round_group_rank_template").trigger("chosen:updated");
  }
}