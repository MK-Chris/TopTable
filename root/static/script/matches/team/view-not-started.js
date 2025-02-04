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
    columnDefs: [{
      // Game number
      targets: 0,
      responsivePriority: 5
    }, {
      // Result (X beat Y)
      targets: 1,
      responsivePriority: 1
    }, {
      // Detailed scores
      targets: 2,
      responsivePriority: 3
    }, {
      // Score (3-1)
      targets: 3,
      responsivePriority: 2
    }, {
      // Match score
      targets: 4,
      responsivePriority: 4
    }]
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
  