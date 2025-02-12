/**
 *  Handle sorting action
 *
 *
 */
$(document).ready(function() {
  $("input.handicap_award").on("change", function(){
    let $this = $(this);
    let match = $this.data("match");
    
    switch($this.val()) {
      case "scratch":
      case "set_later":
        // Scratch, hide the handicap field
        $("#match_" + match + "_handicap").val("0");
        $("#match_" + match + "_handicap").prop("disabled", true);
        $("#match_" + match + "_handicap_div").hide();
        break;
      case "home":
      case "away":
        // Handicap goes to home or away, show the handicap field
        $("#match_" + match + "_handicap").val("");
        $("#match_" + match + "_handicap").prop("disabled", false);
        $("#match_" + match + "_handicap_div").show();
        break;
    }
  });
});