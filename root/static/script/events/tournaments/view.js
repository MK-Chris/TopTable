/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  let rounds_table = $("#rounds").DataTable({
    responsive: true,
    paging: false,
    info: false,
    fixedHeader: true,
    searching: false,
    ordering: false,
  });
  
  /*
    Responsive tabs
  */
  $("div#tabs").responsiveTabs({
    startCollapsed: false,
    setHash: false,
    activate: function(event, tab) {
      if (tab.selector == "#summary") {
        // Redraw the adjustments table
        rounds_table.responsive.recalc();
      }
    }
  });
});