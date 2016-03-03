/**
 *  Handle form fields
 *
 */
$(document).ready(function() {
  /*
    Show / hide the filter divs based on the ticked state of the checkboxes
  */
  $("input.filter-type").on("change", function() {
    var $this           = $(this);
    var form            = $this.data("form");
    var opposite_form   = form === 1 ? 2 : 1;
    var filter          = $this.data("filter");
    var opposite_filter = filter === "defined" ? "custom" : "defined";
    
    if ( $this.prop("checked") ) {
      // Box is ticked, ensure the same box in the other form is also ticked, the opposite box is unticked and show the correct divs, whilst hiding the other ones
      $("div.filter-" + filter).slideDown(400);
      $("div.filter-" + opposite_filter).slideUp(400);
      $("#" + filter + "-filter" + opposite_form).prettyCheckable("check");
      $("input." + opposite_filter + "-filter").prettyCheckable("uncheck");
    } else {
      // Unticked, just hide 
      $("div.filter-" + filter).slideUp(400);
      $("#" + filter + "-filter" + opposite_form).prettyCheckable("uncheck");
    }
  });
  
  /*
    Clear filter button
  */
  $("input.clear-filter").on("change", function() {
    location.href = location.href;
  });
  
  
  /*
    Prevent pressing enter to submit the form
  */
  $(document).on("keypress", "form", function(event) { 
    return event.keyCode != 13;
  });
});