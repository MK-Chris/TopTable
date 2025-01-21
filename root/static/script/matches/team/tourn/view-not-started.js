/**
 *  Match view functions
 *
 */
$(document).ready(function(){
  /*
    Initialise datatables
  */
  var teams_table = $("#teams-table").DataTable({
    responsive: true,
    paging: false,
    info: false,
    ordering: false,
    fixedHeader: true,
    searching: false,
    columns: [
      {responsivePriority: 1}, // Team
      {responsivePriority: 2}, // Division
      {responsivePriority: 4}, // Legs won
      {responsivePriority: 3}, // Legs average
      {responsivePriority: 6}, // Points won
      {responsivePriority: 5} // Points average
    ]
  });
  
  /*
    Initialise responsive tabs
 */
  $("div#tabs").responsiveTabs({
    startCollapsed: false,
    setHash: false,
    active: 1,
    activate: function(event, tab) {
      if (tab.selector == "#teams") {
        // Recalculate the teams table
        teams_table.responsive.recalc();
      }
    }
  });
});
  