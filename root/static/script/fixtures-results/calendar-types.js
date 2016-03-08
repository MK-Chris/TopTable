/**
 *  Handle form fields
 *
 */
$(document).ready(function() {
  /*
    Focus on the type field
  */
  $("#type").focus();
  
  /*
    When the type field changes, submit the form
  */
  $("#type").on("change", function() {
    if ( $(this).val() !== "" ) {
      $("#form").submit();
    }
  });
});