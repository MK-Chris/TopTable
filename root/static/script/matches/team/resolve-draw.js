/**
 *  Handle form fields
 *
 */
$(document).ready(function() {
  let $resolution_type = $("input:radio[name=resolution_type]");
  $resolution_type.on("change", function() {
    let $val = $(this).val();
    
    if ( $val == "new_game" ) {
      // Add a new game, show that div and hide the choose winner one
      $("#new_game_div").show();
      $("#choose_winner_div").hide();
      
      // Reset the chosen winner field
      $("#chosen_winner").val("");
      $("#chosen_winner").trigger("chosen:updated");
    } else if ( $val == "choose_winner" ) {
      // Choose a winner, show that div and hide the new game one
      $("#choose_winner_div").show();
      $("#new_game_div").hide();
      
      // Reset the new game fields
      $("#individual_match_template").val("");
      $("#individual_match_template").trigger("chosen:updated");
      $("#doubles_game").prettyCheckable("uncheck");
      $("#singles_home_player_number").prop("disabled", false);
      $("#singles_home_player_number").val("");
      $("#singles_home_player_number").trigger("chosen:updated");
      $("#singles_away_player_number").prop("disabled", false);
      $("#singles_away_player_number").val("");
      $("#singles_away_player_number").trigger("chosen:updated");
      $("#home_handicap_adj").val(0);
      $("#away_handicap_adj").val(0);
    }
  });
  
  $("#doubles_game").on("change", function() {
    let $this = $(this);
    if ( $this.prop("checked") ) {
      $("#singles_home_player_number").val("");
      $("#singles_home_player_number").prop("disabled", true);
      $("#singles_home_player_number").trigger("chosen:updated");
      $("#singles_away_player_number").val("");
      $("#singles_away_player_number").prop("disabled", true);
      $("#singles_away_player_number").trigger("chosen:updated");
    } else {
      $("#singles_home_player_number").prop("disabled", false);
      $("#singles_home_player_number").trigger("chosen:updated");
      $("#singles_away_player_number").prop("disabled", false);
      $("#singles_away_player_number").trigger("chosen:updated");
    }
  });
});