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
      // Team
      targets: 0,
      responsivePriority: 1
    }, {
      // Division
      targets: 1,
      responsivePriority: 2
    }, {
      // Legs won
      targets: 2,
      responsivePriority: 4
    }, {
      // Legs average
      targets: 3,
      responsivePriority: 3
    }, {
      // Points won
      targets: 4,
      responsivePriority: 6
    }, {
      // Points average
      targets: 5,
      responsivePriority: 5
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
  