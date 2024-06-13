/**
 *  Handle form fields
 *
 */
$(document).ready(function() {
  /*
    Focus on the first available field
  */
  if ( $("#headline").val() == "" ) {
    $("#headline").focus();
  } else if ( $("#article").val() === "" ) {
    $("#article").focus();
  } else {
    // Default back to headline
    $("#headline").focus();
  }
  /*
    Handle pinned article expiry fields being enabled / disabled
  */
  $("#pin_article").on("change", function() {
    if ( $(this).prop("checked") ) {
      // Article is to be pinned, enable expiry fields
      $(".pin_expiry").prop("disabled", false);
      $("#pin-article-details").slideDown(400);
    } else {
      // Article is not to be pinned, disable expiry fields
      $("#pin-article-details").slideUp(400);
      $(".pin_expiry").prop("disabled", true);
    }
    
    $("#pin_expiry_hour").trigger("chosen:updated");
    $("#pin_expiry_minute").trigger("chosen:updated");
  });
});