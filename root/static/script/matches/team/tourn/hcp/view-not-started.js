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
      // Handicap
      targets: 2,
      responsivePriority: 3
    }, {
      // Legs won
      targets: 3,
      responsivePriority: 5
    }, {
      // Legs average
      targets: 4,
      responsivePriority: 4
    }, {
      // Points won
      targets: 5,
      responsivePriority: 7
    }, {
      // Points won
      targets: 6,
      responsivePriority: 6
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
  