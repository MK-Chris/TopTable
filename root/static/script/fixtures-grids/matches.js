/**
 *  Handle form fields
 *
 *
 */
$(document).ready(function(){
  /*
    Repeat fixtures checkbox
  */
  $("#repeat-fixtures").on("change", function(){
    if ( $(this).prop("checked") ) {
      // Hide / disable the repeated fixtures
      $("#repeated-matches").hide();
    } else {
      // Show / enable the repeated fixtures
      $("#repeated-matches").show();
    }
  });
  
  /*
    Focus on first field
  */
  $("#week_1_match_1_home").trigger("chosen:activate");
});