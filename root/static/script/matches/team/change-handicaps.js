/**
 *  Handle sorting action
 *
 *
 */
$(document).ready(function() {
  $("input.handicap_award").on("change", function(){
    switch($this.val()) {
      case "scratch":
      case "set_later":
        // Scratch, hide the handicap field
        $("#round_" + round + "_match_" + match + "_handicap").val("0");
        $("#round_" + round + "_match_" + match + "_handicap").prop("disabled", true);
        $("#round_" + round + "_match_" + match + "_handicap_div").hide();
        break;
      case "home":
      case "away":
        // Handicap goes to home or away, show the handicap field
        $("#round_" + round + "_match_" + match + "_handicap").val("");
        $("#round_" + round + "_match_" + match + "_handicap").prop("disabled", false);
        $("#round_" + round + "_match_" + match + "_handicap_div").show();
        break;
    }
  });
});