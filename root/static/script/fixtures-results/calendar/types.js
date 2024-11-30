/**
 *  Handle form fields
 *
 */
$(document).ready(function() {
  /*
    Focus on the type field
  */
  $("#type").focus();
  $("#type").trigger("chosen:activate");
});