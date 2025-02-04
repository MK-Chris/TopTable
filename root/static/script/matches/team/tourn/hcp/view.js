/**
 *  Match view functions
 *
 */
$(document).ready(function(){
  /*
    Initialise datatables
  */
  var games_table = $("#games-table").DataTable({
    responsive: true,
    paging: false,
    info: false,
    ordering: false,
    fixedHeader: true,
    searching: false,
    columns: [
      {responsivePriority: 5}, // Game number
      {responsivePriority: 1}, // Result (X beat Y)
      {responsivePriority: 3}, // Detailed scores
      {responsivePriority: 2}, // Score (3-1)
      {responsivePriority: 4} // Match score
    ]
  });
  
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
  
  var players_table = $("#players-table").DataTable({
    responsive: true,
    paging: false,
    info: false,
    ordering: false,
    fixedHeader: true,
    searching: false,
    rowGroup: {
      dataSrc: 0
    },
    columns: [
      {visible: false},
      {responsivePriority: 1},
      {responsivePriority: 2},
      {responsivePriority: 3},
      {responsivePriority: 4},
      {responsivePriority: 8},
      {responsivePriority: 5},
      {responsivePriority: 6},
      {responsivePriority: 9},
      {responsivePriority: 7}
    ]
  });
  
  /*
    Initialise responsive tabs
 */
  $("div#tabs").responsiveTabs({
    startCollapsed: false,
    setHash: false,
    activate: function(event, tab) {
      if (tab.selector == "#games") {
        // Recalculate the games table
        games_table.responsive.recalc();
      } else if (tab.selector == "#teams") {
        // Recalculate the teams table
        teams_table.responsive.recalc();
      } else if (tab.selector == "#players") {
        // Recalculate the players tables
        players_table.responsive.recalc();
      }
    }
  });
});
  