/**
 *  Handle form fields
 *
 */
$(document).ready(function() {
  /*
    Copy text
  */
  $("#download_copy").on("click", function() {
    $("#download").select();
    document.execCommand("copy");
  });
  
  $("#subscribe_copy").on("click", function() {
    $("#subscribe").select();
    document.execCommand("copy");
  });
});